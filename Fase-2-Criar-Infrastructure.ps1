# Cria a infraestrutura compartilhada: Docker Network, SQL Server e RabbitMQ

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "Iniciando o provisionamento da Infraestrutura Base..." -ForegroundColor Cyan

if (-not (Get-Command docker -ErrorAction SilentlyContinue))
{
    throw "Docker nao encontrado."
}

docker info | Out-Null

if ($LASTEXITCODE -ne 0)
{
    throw "Docker nao esta disponivel."
}

$swarmStatus = docker info --format '{{.Swarm.LocalNodeState}}'

if ($swarmStatus -ne "active")
{
    throw "Docker Swarm nao esta ativo. Execute a Fase anterior."
}

$envFile = Join-Path $PSScriptRoot ".env.base"

if (-not (Test-Path $envFile))
{
    throw "Arquivo .env.base nao encontrado."
}

Get-Content $envFile | ForEach-Object {

    if ($_ -match '^(.*?)=(.*)$')
    {
        $name  = $matches[1].Trim()
        $value = $matches[2].Trim()

        [System.Environment]::SetEnvironmentVariable(
            $name,
            $value,
            "Process"
        )
    }
}

$sqlOfficialImage = "mcr.microsoft.com/mssql/server:2022-latest"
$sqlImageName = "sqlserver2022:2022"
$sqlAliasExists = @(
    docker image ls --format "{{.Repository}}:{{.Tag}}" |
        Where-Object { $_ -eq $sqlImageName }
)

if ($sqlAliasExists.Count -eq 0) {
    $sqlOfficialExists = @(
        docker image ls --format "{{.Repository}}:{{.Tag}}" |
            Where-Object { $_ -eq $sqlOfficialImage }
    )

    if ($sqlOfficialExists.Count -eq 0) {
        Write-Host "Baixando imagem oficial do SQL Server..." -ForegroundColor Yellow
        docker pull $sqlOfficialImage | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Falha ao baixar a imagem oficial do SQL Server."
        }
    }

    Write-Host "Criando alias local '$sqlImageName' para o SQL Server..." -ForegroundColor Yellow
    docker tag $sqlOfficialImage $sqlImageName
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao criar o alias local '$sqlImageName'."
    }
}

$sqlOfficialReference = @(
    docker image ls --format "{{.Repository}}:{{.Tag}}" |
        Where-Object { $_ -eq $sqlOfficialImage }
)
if ($sqlOfficialReference.Count -gt 0) {
    docker image rm $sqlOfficialImage | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao remover a referencia original '$sqlOfficialImage' apos criar o alias local."
    }
}

Write-Host "Imagem SQL Server disponivel como '$sqlImageName'." -ForegroundColor Green

$requiredSecrets = @(
    "sql_sa_password",
    "rabbitmq_password",
    "jwt_key"
)

foreach ($secret in $requiredSecrets)
{
    $exists = docker secret ls --format '{{.Name}}' | Where-Object { $_ -eq $secret }

    if (-not $exists)
    {
        throw "Secret obrigatorio nao encontrado: $secret"
    }
}

$networkExists =
    docker network ls --format '{{.Name}}' | Where-Object { $_ -eq $env:DOCKER_NETWORK }

if (-not $networkExists)
{
    Write-Host "Criando rede Docker '$($env:DOCKER_NETWORK)'..." -ForegroundColor Yellow

    docker network create --driver overlay --attachable $env:DOCKER_NETWORK | Out-Null

    if ($LASTEXITCODE -ne 0)
    {
        throw "Falha ao criar rede Docker."
    }

    Write-Host "Rede Docker criada." -ForegroundColor Green
}
else
{
    Write-Host "Rede Docker ja existe." -ForegroundColor Gray
}

$sqlExists =
    docker service ls --format '{{.Name}}' | Where-Object { $_ -eq $env:SQL_CONTAINER }

if (-not $sqlExists)
{
    Write-Host "Criando servico SQL Server '$env:SQL_CONTAINER'..." -ForegroundColor Yellow
    Write-Host "O Docker Swarm gera nomes de container-task com slot e ID; o hostname e o nome DNS do servico permanecem '$env:SQL_CONTAINER'." -ForegroundColor Gray

    docker service create `
        --name $env:SQL_CONTAINER `
        --hostname $env:SQL_CONTAINER `
        --network $env:DOCKER_NETWORK `
        --secret sql_sa_password `
        -e ACCEPT_EULA=Y `
        -e MSSQL_SA_PASSWORD_FILE=/run/secrets/sql_sa_password `
        --mount type=volume,source=$env:SQL_VOLUME,target=/var/opt/mssql `
        -p 1433:1433 `
        $sqlImageName | Out-Null

    if ($LASTEXITCODE -ne 0)
    {
        throw "Falha ao criar o servico SQL Server."
    }

    Write-Host "SQL Server criado. O nome DNS estavel do servico e '$env:SQL_CONTAINER'." -ForegroundColor Green
}
else
{
    Write-Host "SQL Server ja existe." -ForegroundColor Gray

    $sqlHostname = docker service inspect --format '{{.Spec.TaskTemplate.ContainerSpec.Hostname}}' $env:SQL_CONTAINER
    if ($LASTEXITCODE -ne 0)
    {
        throw "Falha ao inspecionar o servico SQL Server '$env:SQL_CONTAINER'."
    }

    if ($sqlHostname -ne $env:SQL_CONTAINER)
    {
        Write-Host "Atualizando hostname interno do SQL Server para '$env:SQL_CONTAINER'..." -ForegroundColor Yellow
        docker service update --hostname $env:SQL_CONTAINER $env:SQL_CONTAINER | Out-Null
        if ($LASTEXITCODE -ne 0)
        {
            throw "Falha ao atualizar o hostname interno do servico SQL Server."
        }
    }
}

$rabbitExists = docker service ls --format '{{.Name}}' | Where-Object { $_ -eq $env:RABBIT_CONTAINER }

if (-not $rabbitExists)
{
    Write-Host "Criando RabbitMQ..." -ForegroundColor Yellow

    docker service create `
        --name $env:RABBIT_CONTAINER `
        --network $env:DOCKER_NETWORK `
        --secret source=rabbitmq_password,target=rabbitmq_password `
        --mount type=volume,source=$env:RABBIT_VOLUME,target=/var/lib/rabbitmq `
        -p 5672:5672 `
        -p 15672:15672 `
        rabbitmq:3-management | Out-Null

    if ($LASTEXITCODE -ne 0)
    {
        throw "Falha ao criar o servico RabbitMQ."
    }

    Write-Host "RabbitMQ criado." -ForegroundColor Green
}
else
{
    Write-Host "RabbitMQ ja existe." -ForegroundColor Gray
}

Write-Host "Aguardando RabbitMQ responder..." -ForegroundColor Yellow

$maxRetries = 30
$retryCount = 0
$portReady = $false

while (-not $portReady -and $retryCount -lt $maxRetries)
{
    $result =
        Test-NetConnection `
            -ComputerName "localhost" `
            -Port 5672 `
            -WarningAction SilentlyContinue

    if ($result.TcpTestSucceeded)
    {
        $portReady = $true
    }
    else
    {
        Start-Sleep -Seconds 2
        $retryCount++
    }
}

if (-not $portReady)
{
    throw "RabbitMQ nao respondeu na porta 5672."
}
else {
    $containerId = docker ps `
        --filter "label=com.docker.swarm.service.name=$env:RABBIT_CONTAINER" `
        --format "{{.ID}}" |
        Select-Object -First 1

    if ([string]::IsNullOrWhiteSpace($containerId)) {
        throw "Nao foi localizado um container ativo para o servico RabbitMQ '$env:RABBIT_CONTAINER'."
    }

    docker exec $containerId rabbitmqctl await_startup --quiet

    $rabbitPassword =
        (docker exec $containerId cat /run/secrets/rabbitmq_password).Trim()

    $rabbitUserExists = docker exec $containerId rabbitmqctl list_users --formatter json |
        Select-String -SimpleMatch "`"user`":`"$($env:SPRING_RABBITMQ_USERNAME)`""

    if ($rabbitUserExists) {
        Write-Host "Atualizando usuario '$env:SPRING_RABBITMQ_USERNAME'..." -ForegroundColor Yellow
        docker exec $containerId rabbitmqctl change_password `
            $env:SPRING_RABBITMQ_USERNAME `
            $rabbitPassword | Out-Null
    }
    else {
        Write-Host "Criando usuario adicional '$env:SPRING_RABBITMQ_USERNAME'..." -ForegroundColor Yellow
        docker exec $containerId rabbitmqctl add_user `
            $env:SPRING_RABBITMQ_USERNAME `
            $rabbitPassword | Out-Null
    }

    docker exec $containerId rabbitmqctl set_user_tags `
        $env:SPRING_RABBITMQ_USERNAME `
        administrator | Out-Null

    docker exec $containerId rabbitmqctl set_permissions `
        -p / `
        $env:SPRING_RABBITMQ_USERNAME `
        ".*" ".*" ".*" | Out-Null

    Write-Host "Usuario '$env:SPRING_RABBITMQ_USERNAME' criado." -ForegroundColor Green
    Write-Host "Usuario 'guest' permanece ativo por padrao." -ForegroundColor Green
}

Write-Host "Essa Fase foi concluida com sucesso." -ForegroundColor Green