# D:\Projetos\SaaS_Enterprise_Microsservicos\Fase-2-Criar-Infrastructure.ps1
# cria a infraestrutura, Rede, SQL Server, RabbitMQ (usando Docker Secrets)

$ErrorActionPreference = "Stop"

# Carregar variáveis do .env.base
Get-Content .env.base | ForEach-Object {
    if ($_ -match "^(.*?)=(.*)$") {
        $name  = $matches[1].Trim()
        $value = $matches[2].Trim()
        [System.Environment]::SetEnvironmentVariable($name, $value)
    }
}

Write-Host "🚀 Iniciando o provisionamento da Infraestrutura Base..." -ForegroundColor Cyan

# 1. CRIAR REDE DOCKER (overlay)
$networkExists = docker network ls --format '{{.Name}}' | Where-Object { $_ -eq $env:DOCKER_NETWORK }
if (-not $networkExists) {
    Write-Host "🌐 Criando a rede overlay Docker '$env:DOCKER_NETWORK'..." -ForegroundColor Yellow

    docker network create --driver overlay $env:DOCKER_NETWORK | Out-Null

    Write-Host "✅ Rede Docker '$env:DOCKER_NETWORK' criada." -ForegroundColor Green
} else {
    Write-Host "✅ Rede overlay Docker '$env:DOCKER_NETWORK' ja existe. Nenhuma acao necessaria." -ForegroundColor Gray
}

# 2. SUBIR SQL SERVER 2022
$sqlExists = docker service ls --format '{{.Name}}' | Where-Object { $_ -eq $env:SQL_CONTAINER }
if (-not $sqlExists) {
    Write-Host "🐘 Subindo servico do SQL Server 2022..." -ForegroundColor Yellow

    docker service create `
        --name $env:SQL_CONTAINER `
        --network $env:DOCKER_NETWORK `
        --secret sql_sa_password `
        -e 'ACCEPT_EULA=Y' `
        -e 'MSSQL_SA_PASSWORD_FILE=/run/secrets/sql_sa_password' `
        --mount type=volume,source=$env:SQL_VOLUME,target=/var/opt/mssql `
        -p 1433:1433 `
        mcr.microsoft.com/mssql/server:2022-latest | Out-Null

    Write-Host "✅ Servico '$env:SQL_CONTAINER' criado com secrets." -ForegroundColor Green
} else {
    Write-Host "✅ Servico '$env:SQL_CONTAINER' ja existe." -ForegroundColor Gray
}

# 3. SUBIR RABBITMQ
$rabbitExists = docker service ls --format '{{.Name}}' | Where-Object { $_ -eq $env:RABBIT_CONTAINER }
if (-not $rabbitExists) {
    Write-Host "🐇 Subindo servico do RabbitMQ..." -ForegroundColor Yellow

    docker service create `
        --name $env:RABBIT_CONTAINER `
        --network $env:DOCKER_NETWORK `
        --secret rabbitmq_password `
        --mount type=volume,source=$env:RABBIT_VOLUME,target=/var/lib/rabbitmq `
        -p 5672:5672 `
        -p 15672:15672 `
        rabbitmq:3-management | Out-Null

    Write-Host "⏳ Aguardando RabbitMQ inicializar (porta 5672)..." -ForegroundColor Yellow
    $maxRetries = 30; $retryCount = 0; $portReady = $false
    while (-not $portReady -and $retryCount -lt $maxRetries) {
        $result = Test-NetConnection -ComputerName "localhost" -Port 5672
        if ($result.TcpTestSucceeded) { $portReady = $true } else { Start-Sleep -Seconds 2; $retryCount++ }
    }
    if (-not $portReady) { throw "❌ RabbitMQ nao respondeu na porta 5672 apos $($maxRetries*2) segundos." }

    # Obter o ID do container da task do RabbitMQ
    $taskId = docker ps --filter "name=$env:RABBIT_CONTAINER" --format "{{.ID}}" | Select-Object -First 1
    
    if (-not $taskId) { throw "❌ Nao foi possivel localizar o container da task do RabbitMQ." }

    Write-Host "⏳ Confirmando inicializacao completa do RabbitMQ..." -ForegroundColor Yellow

    docker exec $taskId rabbitmqctl await_startup --quiet

    # Ler a senha diretamente do arquivo de secret dentro do container
    $rabbitPassword = docker exec $taskId cat /run/secrets/rabbitmq_password

    Write-Host "🔑 Criando usuario adicional '$env:SPRING_RABBITMQ_USERNAME'..." -ForegroundColor Yellow

    docker exec $taskId rabbitmqctl add_user $env:SPRING_RABBITMQ_USERNAME $rabbitPassword | Out-Null
    docker exec $taskId rabbitmqctl set_user_tags $env:SPRING_RABBITMQ_USERNAME administrator | Out-Null
    docker exec $taskId rabbitmqctl set_permissions -p / $env:SPRING_RABBITMQ_USERNAME ".*" ".*" ".*" | Out-Null

    Write-Host "✅ Usuario '$env:SPRING_RABBITMQ_USERNAME' criado." -ForegroundColor Green
    Write-Host "👤 Usuario 'guest' permanece ativo por padrao." -ForegroundColor Green
} else {
    Write-Host "✅ Servico '$env:RABBIT_CONTAINER' ja existe." -ForegroundColor Yellow
}

Write-Host "`n🎉 Concluido! Infraestrutura base criada com Rede, SQL Server e RabbitMQ usando Docker Secrets." -ForegroundColor Cyan
