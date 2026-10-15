# D:\Projetos\SaaS_Enterprise_Microsservicos\Fase-1-Criar-Secrets.ps1
# cria os secrets do Docker e inicializa o Docker Swarm

$ErrorActionPreference = "Stop"

Write-Host "🚀 Iniciando Fase-1: Configuracao de Docker Swarm e Secrets..." -ForegroundColor Cyan

# 1. Verificar se o Swarm já está inicializado
$swarmStatus = docker info --format '{{.Swarm.LocalNodeState}}'

if ($swarmStatus -ne "active") {
    Write-Host "⚠️ Docker Swarm nao esta ativo. Inicializando..." -ForegroundColor Yellow

    docker swarm init | Out-Null

    Write-Host "✅ Docker Swarm inicializado com sucesso." -ForegroundColor Green
} else {
    Write-Host "✅ Docker Swarm ja esta ativo." -ForegroundColor Gray
}

# 2. Definir secrets e arquivos correspondentes
$secrets = @{
    "sql_sa_password"    = "D:\Projetos\SaaS_Enterprise_Microsservicos\secrets_sql_sa_password.txt"
    "rabbitmq_password"  = "D:\Projetos\SaaS_Enterprise_Microsservicos\secrets_rabbitmq_password.txt"
    "jwt_key"            = "D:\Projetos\SaaS_Enterprise_Microsservicos\secrets_jwt_key.txt"
}

# 3. Criar secrets se não existirem
foreach ($secret in $secrets.Keys) {
    $exists = docker secret ls --format '{{.Name}}' | Where-Object { $_ -eq $secret }
    if (-not $exists) {
        Write-Host "🔑 Criando secret '$secret'..." -ForegroundColor Yellow

        docker secret create $secret $secrets[$secret] | Out-Null

        Write-Host "✅ Secret '$secret' criado com sucesso." -ForegroundColor Green
    } else {
        Write-Host "✅ Secret '$secret' ja existe. Nenhuma acao necessaria." -ForegroundColor Gray
    }
}

Write-Host "`n🎉 Concluido! Docker Swarm e Secrets estao prontos para uso." -ForegroundColor Cyan