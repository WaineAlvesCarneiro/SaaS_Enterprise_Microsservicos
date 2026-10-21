# D:\Projetos\SaaS_Enterprise_Microsservicos\Fase-2-Criar-Infrastructure.ps1
# Cria a infraestrutura compartilhada: Docker Network, SQL Server e RabbitMQ

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "🚀 Iniciando o provisionamento da Infraestrutura Base..." -ForegroundColor Cyan

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
    throw "Docker Swarm nao esta ativo. Execute a Fase-1 primeiro."
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
    Write-Host "🌐 Criando rede Docker '$($env:DOCKER_NETWORK)'..." -ForegroundColor Yellow

    docker network create --driver overlay $env:DOCKER_NETWORK | Out-Null

    if ($LASTEXITCODE -ne 0)
    {
        throw "Falha ao criar rede Docker."
    }

    Write-Host "✅ Rede Docker criada." -ForegroundColor Green
}
else
{
    Write-Host "✅ Rede Docker ja existe." -ForegroundColor Gray
}

$sqlExists =
    docker service ls --format '{{.Name}}' | Where-Object { $_ -eq $env:SQL_CONTAINER }

if (-not $sqlExists)
{
    Write-Host "🐘 Criando SQL Server..." -ForegroundColor Yellow

    docker service create `
        --name $env:SQL_CONTAINER `
        --network $env:DOCKER_NETWORK `
        --secret sql_sa_password `
        -e ACCEPT_EULA=Y `
        -e MSSQL_SA_PASSWORD_FILE=/run/secrets/sql_sa_password `
        --mount type=volume,source=$env:SQL_VOLUME,target=/var/opt/mssql `
        -p 1433:1433 `
        mcr.microsoft.com/mssql/server:2022-latest | Out-Null

    if ($LASTEXITCODE -ne 0)
    {
        throw "Falha ao criar o servico SQL Server."
    }

    Write-Host "✅ SQL Server criado." -ForegroundColor Green
}
else
{
    Write-Host "✅ SQL Server ja existe." -ForegroundColor Gray
}

$rabbitExists = docker service ls --format '{{.Name}}' | Where-Object { $_ -eq $env:RABBIT_CONTAINER }

if (-not $rabbitExists)
{
    Write-Host "🐇 Criando RabbitMQ..." -ForegroundColor Yellow

    docker service create `
        --name $env:RABBIT_CONTAINER `
        --network $env:DOCKER_NETWORK `
        --mount type=volume,source=$env:RABBIT_VOLUME,target=/var/lib/rabbitmq `
        -p 5672:5672 `
        -p 15672:15672 `
        rabbitmq:3-management | Out-Null

    if ($LASTEXITCODE -ne 0)
    {
        throw "Falha ao criar o servico RabbitMQ."
    }

    Write-Host "✅ RabbitMQ criado." -ForegroundColor Green
}
else
{
    Write-Host "✅ RabbitMQ ja existe." -ForegroundColor Gray
}

Write-Host "⏳ Aguardando RabbitMQ responder..." -ForegroundColor Yellow

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

Write-Host ""
Write-Host "🎉 Infraestrutura compartilhada pronta." -ForegroundColor Green
Write-Host ""
Write-Host "Componentes ativos:" -ForegroundColor Cyan
Write-Host "- Docker Swarm" -ForegroundColor Gray
Write-Host "- Rede: $($env:DOCKER_NETWORK)" -ForegroundColor Gray
Write-Host "- SQL Server: $($env:SQL_CONTAINER)" -ForegroundColor Gray
Write-Host "- RabbitMQ: $($env:RABBIT_CONTAINER)" -ForegroundColor Gray