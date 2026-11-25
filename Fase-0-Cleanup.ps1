# remove serviços, volumes, secrets e rede overlay

$ErrorActionPreference = "Stop"

Write-Host "Iniciando limpeza da infraestrutura..." -ForegroundColor Cyan

$envFile = Join-Path $PSScriptRoot ".env.base"
$configuration = @{}

if (Test-Path $envFile)
{
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^(.*?)=(.*)$')
        {
            $configuration[$matches[1].Trim()] = $matches[2].Trim()
        }
    }
}

# Verifica se o Swarm já está ativo
$swarmState = docker info --format '{{.Swarm.LocalNodeState}}' 2>$null

if ($swarmState -ne "active") {
    Write-Host "Docker Swarm nao esta inicializado. Inicializando..." -ForegroundColor Yellow

    docker swarm init

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao inicializar o Docker Swarm."
    }

    Write-Host "Docker Swarm inicializado com sucesso." -ForegroundColor Green
}
else {
    Write-Host "Docker Swarm ja esta ativo." -ForegroundColor Green
}

$sqlServiceName = if ($configuration.ContainsKey("SQL_CONTAINER") -and $configuration["SQL_CONTAINER"]) { $configuration["SQL_CONTAINER"] } else { "sqlserver2022" }
$rabbitServiceName = if ($configuration.ContainsKey("RABBIT_CONTAINER") -and $configuration["RABBIT_CONTAINER"]) { $configuration["RABBIT_CONTAINER"] } else { "rabbitmq" }
$sqlVolumeName = if ($configuration.ContainsKey("SQL_VOLUME") -and $configuration["SQL_VOLUME"]) { $configuration["SQL_VOLUME"] } else { "sqlserver_data" }
$rabbitVolumeName = if ($configuration.ContainsKey("RABBIT_VOLUME") -and $configuration["RABBIT_VOLUME"]) { $configuration["RABBIT_VOLUME"] } else { "rabbitmq_data" }
$networkName = if ($configuration.ContainsKey("DOCKER_NETWORK") -and $configuration["DOCKER_NETWORK"]) { $configuration["DOCKER_NETWORK"] } else { "infra_net" }
$authenticationStackNames = @("authentication-api", "Authentication.API")
$authenticationComposeProjectNames = @("authentication", "authentication-api")
$authenticationImageNames = @("authentication-api:local", "authenticationapi:dev")
$authenticationBuildVolumes = @(
    "authentication_api_bin",
    "authentication_api_obj",
    "authentication_application_bin",
    "authentication_application_obj",
    "authentication_domain_bin",
    "authentication_domain_obj",
    "authentication_infrastructure_bin",
    "authentication_infrastructure_obj",
    "authentication_nuget_packages"
)

# 1. Remover stacks atual e legada da Authentication
$existingStacks = @(docker stack ls --format '{{.Name}}')
if ($LASTEXITCODE -ne 0) {
    throw "Falha ao listar as stacks Docker."
}

$removedAuthenticationStack = $false
foreach ($stackName in $authenticationStackNames) {
    if ($stackName -in $existingStacks) {
        Write-Host "Removendo stack '$stackName'..." -ForegroundColor Yellow
        docker stack rm $stackName | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Falha ao remover a stack '$stackName'."
        }
        $removedAuthenticationStack = $true
    }
    else {
        Write-Host "Stack '$stackName' nao encontrada. Nenhuma acao necessaria." -ForegroundColor Gray
    }
}

if ($removedAuthenticationStack) {
    Start-Sleep -Seconds 15
}

# 2. Remover containers de desenvolvimento da Authentication no Docker Compose
foreach ($composeProjectName in $authenticationComposeProjectNames) {
    $composeContainers = @(
        docker container ls -aq `
            --filter "label=com.docker.compose.project=$composeProjectName" `
            --filter "label=com.docker.compose.service=api"
    )
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao listar containers Compose do projeto '$composeProjectName'."
    }

    foreach ($containerId in $composeContainers) {
        if (-not [string]::IsNullOrWhiteSpace($containerId)) {
            Write-Host "Removendo container Docker da Authentication '$containerId'..." -ForegroundColor Yellow
            docker container rm -f $containerId | Out-Null
            if ($LASTEXITCODE -ne 0) {
                throw "Falha ao remover container Docker '$containerId'."
            }
        }
    }
}

# 3. Remover serviços (SQL Server e RabbitMQ)
$services = @($sqlServiceName, $rabbitServiceName)

foreach ($svc in $services) {
    $exists = docker service ls --format '{{.Name}}' | Where-Object { $_ -eq $svc }
    if ($exists) {
        Write-Host "Removendo servico '$svc'..." -ForegroundColor Yellow

        docker service rm $svc | Out-Null
        
        Write-Host "Servico '$svc' removido." -ForegroundColor Green
    } else {
        Write-Host "Servico '$svc' nao encontrado. Nenhuma acao necessaria." -ForegroundColor Gray
    }
}

# 4. Remover volumes (SQL Server e RabbitMQ)
$volumes = @($sqlVolumeName, $rabbitVolumeName)

foreach ($vol in $volumes) {
    $exists = docker volume ls --format '{{.Name}}' | Where-Object { $_ -eq $vol }
    if ($exists) {
        Write-Host "Removendo volume '$vol'..." -ForegroundColor Yellow

        docker volume rm $vol | Out-Null

        Write-Host "Volume '$vol' removido." -ForegroundColor Green
    } else {
        Write-Host "Volume '$vol' nao encontrado. Nenhuma acao necessaria." -ForegroundColor Gray
    }
}

# 5. Remover volumes Docker de build e restore da Authentication
foreach ($volumeName in $authenticationBuildVolumes) {
    $exists = docker volume ls --format '{{.Name}}' | Where-Object { $_ -eq $volumeName }
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao listar volumes Docker."
    }

    if ($exists) {
        Write-Host "Removendo volume de build '$volumeName'..." -ForegroundColor Yellow
        docker volume rm $volumeName | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Falha ao remover volume Docker '$volumeName'."
        }
        Write-Host "Volume '$volumeName' removido." -ForegroundColor Green
    }
    else {
        Write-Host "Volume '$volumeName' nao encontrado. Nenhuma acao necessaria." -ForegroundColor Gray
    }
}

# 6. Remover secrets
$secrets = @("sql_sa_password", "rabbitmq_password", "jwt_key")

foreach ($secret in $secrets) {
    $exists = docker secret ls --format '{{.Name}}' | Where-Object { $_ -eq $secret }
    if ($exists) {
        Write-Host "Removendo secret '$secret'..." -ForegroundColor Yellow

        docker secret rm $secret | Out-Null

        Write-Host "Secret '$secret' removido." -ForegroundColor Green
    } else {
        Write-Host "Secret '$secret' nao encontrado. Nenhuma acao necessaria." -ForegroundColor Gray
    }
}

# 7. Remover rede overlay
$network = $networkName

$exists = docker network ls --format '{{.Name}}' |
    Where-Object { $_ -eq $network }

if ($exists) {
    Write-Host "Removendo rede '$network'..." -ForegroundColor Yellow

    docker network rm $network | Out-Null

    Write-Host "Rede '$network' removida." -ForegroundColor Green
}
else {
    Write-Host "Rede '$network' nao encontrada." -ForegroundColor Gray
}

# 8. Remover imagens Docker da Authentication
$existingImages = @(
    docker image ls --format "{{.Repository}}:{{.Tag}}"
)
if ($LASTEXITCODE -ne 0) {
    throw "Falha ao listar as imagens Docker."
}

foreach ($imageName in $authenticationImageNames) {
    if ($imageName -in $existingImages) {
        Write-Host "Removendo imagem '$imageName'..." -ForegroundColor Yellow
        docker image rm -f $imageName | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Falha ao remover a imagem '$imageName'."
        }
        Write-Host "Imagem '$imageName' removida." -ForegroundColor Green
    }
    else {
        Write-Host "Imagem '$imageName' nao encontrada. Nenhuma acao necessaria." -ForegroundColor Gray
    }
}

# 9. Remover artefatos locais de build da API
$apiBuildDirectories = @(
    (Join-Path $PSScriptRoot "Servicos\Authentication\Authentication.API\bin"),
    (Join-Path $PSScriptRoot "Servicos\Authentication\Authentication.API\obj")
)

foreach ($directory in $apiBuildDirectories) {
    if (Test-Path -LiteralPath $directory -PathType Container) {
        Write-Host "Removendo artefatos de build '$directory'..." -ForegroundColor Yellow
        Remove-Item -LiteralPath $directory -Recurse -Force
        Write-Host "Artefatos removidos: $directory" -ForegroundColor Green
    }
    else {
        Write-Host "Artefatos '$directory' nao encontrados. Nenhuma acao necessaria." -ForegroundColor Gray
    }
}

Write-Host "Essa Fase foi concluida com sucesso." -ForegroundColor Green
