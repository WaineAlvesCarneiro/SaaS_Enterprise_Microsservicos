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

$sqlServiceName = if ($configuration.ContainsKey("SQL_CONTAINER") -and $configuration["SQL_CONTAINER"]) { $configuration["SQL_CONTAINER"] } else { "sqlserver2022" }
$rabbitServiceName = if ($configuration.ContainsKey("RABBIT_CONTAINER") -and $configuration["RABBIT_CONTAINER"]) { $configuration["RABBIT_CONTAINER"] } else { "rabbitmq" }
$sqlVolumeName = if ($configuration.ContainsKey("SQL_VOLUME") -and $configuration["SQL_VOLUME"]) { $configuration["SQL_VOLUME"] } else { "sqlserver_data" }
$rabbitVolumeName = if ($configuration.ContainsKey("RABBIT_VOLUME") -and $configuration["RABBIT_VOLUME"]) { $configuration["RABBIT_VOLUME"] } else { "rabbitmq_data" }
$networkName = if ($configuration.ContainsKey("DOCKER_NETWORK") -and $configuration["DOCKER_NETWORK"]) { $configuration["DOCKER_NETWORK"] } else { "infra_net" }
$authenticationStackNames = @("authentication", "authentication-api")
$authenticationImageName = "authentication-api:local"

# 1. Remover as stacks atual e legada da Authentication
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
    Write-Host "Stacks da Authentication removidas." -ForegroundColor Green
}

# 2. Remover serviços (SQL Server e RabbitMQ)
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

Start-Sleep -Seconds 15

# 3. Remover volumes (SQL e RabbitMQ)
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

# 4. Remover secrets
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

# 5. Remover rede overlay
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

# 6. Remover a imagem criada pela Fase 11
$authenticationImageExists = @(
    docker image ls --format "{{.Repository}}:{{.Tag}}" |
        Where-Object { $_ -eq $authenticationImageName }
)
if ($LASTEXITCODE -ne 0) {
    throw "Falha ao listar as imagens Docker."
}

if ($authenticationImageExists.Count -gt 0) {
    Write-Host "Removendo imagem '$authenticationImageName'..." -ForegroundColor Yellow
    docker image rm -f $authenticationImageName | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao remover a imagem '$authenticationImageName'."
    }
    Write-Host "Imagem '$authenticationImageName' removida." -ForegroundColor Green
}
else {
    Write-Host "Imagem '$authenticationImageName' nao encontrada. Nenhuma acao necessaria." -ForegroundColor Gray
}

# 7. Remover artefatos locais de build da API
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
