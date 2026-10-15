# D:\Projetos\SaaS_Enterprise_Microsservicos\Fase-0-Cleanup.ps1
# remove serviços, volumes, secrets e rede overlay

$ErrorActionPreference = "Stop"

Write-Host "🧹 Iniciando limpeza da infraestrutura..." -ForegroundColor Cyan

# 1. Remover serviços (SQL Server e RabbitMQ)
$services = @("sqlserver2022", "rabbitmq")

foreach ($svc in $services) {
    $exists = docker service ls --format '{{.Name}}' | Where-Object { $_ -eq $svc }
    if ($exists) {
        Write-Host "🗑️ Removendo serviço '$svc'..." -ForegroundColor Yellow

        docker service rm $svc | Out-Null
        
        Write-Host "✅ Servico '$svc' removido." -ForegroundColor Green
    } else {
        Write-Host "ℹ️ Servico '$svc' nao encontrado. Nenhuma acao necessaria." -ForegroundColor Gray
    }
}

if ($exists) {
    Start-Sleep -Seconds 15
}

# 2. Remover volumes (SQL e RabbitMQ)
$volumes = @("sqlserver_data", "rabbitmq_data")

foreach ($vol in $volumes) {
    $exists = docker volume ls --format '{{.Name}}' | Where-Object { $_ -eq $vol }
    if ($exists) {
        Write-Host "🗑️ Removendo volume '$vol'..." -ForegroundColor Yellow

        docker volume rm $vol | Out-Null

        Write-Host "✅ Volume '$vol' removido." -ForegroundColor Green
    } else {
        Write-Host "ℹ️ Volume '$vol' nao encontrado. Nenhuma acao necessaria." -ForegroundColor Gray
    }
}

# 3. Remover secrets
$secrets = @("sql_sa_password", "rabbitmq_password", "jwt_key")

foreach ($secret in $secrets) {
    $exists = docker secret ls --format '{{.Name}}' | Where-Object { $_ -eq $secret }
    if ($exists) {
        Write-Host "🗑️ Removendo secret '$secret'..." -ForegroundColor Yellow

        docker secret rm $secret | Out-Null

        Write-Host "✅ Secret '$secret' removido." -ForegroundColor Green
    } else {
        Write-Host "ℹ️ Secret '$secret' nao encontrado. Nenhuma acao necessaria." -ForegroundColor Gray
    }
}

# 4. Remover rede overlay
$network = @("infra_net")

$exists = docker network ls --format '{{.Name}}' | Where-Object { $_ -eq $network }
if ($exists) {
    Write-Host "🗑️ Removendo rede 'overlay $network'..." -ForegroundColor Yellow
        
    docker network rm $network | Out-Null
        
    Write-Host "✅ Rede 'overlay $network' removida." -ForegroundColor Green
} else {
    Write-Host "ℹ️ Rede 'overlay $network' nao existe. Nenhuma acao necessaria." -ForegroundColor Gray
}

Write-Host "`n🎉 Limpeza concluida! Servicos, volumes, secrets e rede overlay $network removidos." -ForegroundColor Green
