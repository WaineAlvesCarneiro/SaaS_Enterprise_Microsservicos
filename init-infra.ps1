# init-infra.ps1
$ErrorActionPreference = "Stop"

Write-Host "🚀 Iniciando o provisionamento da Infraestrutura Base (Fase 1)..." -ForegroundColor Green

# 1. CRIAR REDE DOCKER (infra_net)
$networkName = "infra_net"
$networkExists = docker network ls --format '{{.Name}}' | Select-String -Pattern "^$networkName$" -SimpleMatch

if (-not $networkExists) {
    Write-Host "🌐 Criando a rede Docker '$networkName'..." -ForegroundColor Yellow
    docker network create $networkName | Out-Null
} else {
    Write-Host "✅ Rede Docker '$networkName' já existe." -ForegroundColor Gray
}

# 2. CRIAR VOLUMES DOCKER
$volumes = @("sqlserver_data", "rabbitmq_data")
foreach ($vol in $volumes) {
    $volExists = docker volume ls --format '{{.Name}}' | Select-String -Pattern "^$vol$" -SimpleMatch
    if (-not $volExists) {
        Write-Host "💾 Criando volume Docker '$vol'..." -ForegroundColor Yellow
        docker volume create $vol | Out-Null
    } else {
        Write-Host "✅ Volume Docker '$vol' já existe." -ForegroundColor Gray
    }
}

# 3. SUBIR SQL SERVER 2022
$sqlContainer = "sqlserver2022"
$sqlExists = docker ps -a --format '{{.Names}}' | Select-String -Pattern "^$sqlContainer$" -SimpleMatch

if (-not $sqlExists) {
    Write-Host "🐘 Subindo container do SQL Server 2022..." -ForegroundColor Yellow
    docker run -d `
        --name $sqlContainer `
        --network $networkName `
        -e 'ACCEPT_EULA=Y' `
        -e 'MSSQL_SA_PASSWORD=Senh@Forte2026!' `
        -v sqlserver_data:/var/opt/mssql `
        -p 1433:1433 `
        mcr.microsoft.com/mssql/server:2022-latest | Out-Null
} else {
    Write-Host "✅ Container '$sqlContainer' já existe. Garantindo que está rodando..." -ForegroundColor Gray
    docker start $sqlContainer | Out-Null
}

# 4. SUBIR RABBITMQ
$rabbitContainer = "rabbitmq"
$rabbitExists = docker ps -a --format '{{.Names}}' | Select-String -Pattern "^$rabbitContainer$" -SimpleMatch

if (-not $rabbitExists) {
    Write-Host "🐇 Subindo container do RabbitMQ..." -ForegroundColor Yellow
    docker run -d `
        --name $rabbitContainer `
        --network $networkName `
        -v rabbitmq_data:/var/lib/rabbitmq `
        -p 5672:5672 `
        -p 15672:15672 `
        rabbitmq:3-management | Out-Null
} else {
    Write-Host "✅ Container '$rabbitContainer' já existe. Garantindo que está rodando..." -ForegroundColor Gray
    docker start $rabbitContainer | Out-Null
}

Write-Host "`n✅ Fase 1 concluída com sucesso! Infraestrutura base pronta e integrada na rede '$networkName'." -ForegroundColor Green