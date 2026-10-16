# D:\Projetos\SaaS_Enterprise_Microsservicos\Fase-1-Criar-Secrets.ps1
# Cria os Docker Secrets e inicializa o Docker Swarm

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "🚀 Iniciando Fase-1: Configuracao de Docker Swarm e Secrets..." -ForegroundColor Cyan

# VALIDAR DOCKER

if (-not (Get-Command docker -ErrorAction SilentlyContinue))
{
    throw "Docker nao encontrado."
}

docker info | Out-Null

if ($LASTEXITCODE -ne 0)
{
    throw "Docker nao esta disponivel."
}

# VALIDAR SWARM

$swarmStatus = docker info --format '{{.Swarm.LocalNodeState}}'

if ($swarmStatus -eq "inactive")
{
    Write-Host "⚠️ Docker Swarm nao esta ativo. Inicializando..." -ForegroundColor Yellow

    docker swarm init | Out-Null

    if ($LASTEXITCODE -ne 0)
    {
        throw "Falha ao inicializar o Docker Swarm."
    }

    Write-Host "✅ Docker Swarm inicializado com sucesso." -ForegroundColor Green
}
elseif ($swarmStatus -ne "active")
{
    throw "Docker Swarm em estado invalido: $swarmStatus"
}
else
{
    Write-Host "✅ Docker Swarm ja esta ativo." -ForegroundColor Gray
}

# DEFINIR SECRETS

$secrets = @{
    "sql_sa_password"    = Join-Path $PSScriptRoot "secrets_sql_sa_password.txt"
    "rabbitmq_password"  = Join-Path $PSScriptRoot "secrets_rabbitmq_password.txt"
    "jwt_key"            = Join-Path $PSScriptRoot "secrets_jwt_key.txt"
}

# VALIDAR ARQUIVOS DE SECRET

foreach ($file in $secrets.Values)
{
    if (-not (Test-Path $file))
    {
        throw "Arquivo de secret nao encontrado: $file"
    }
}

# CRIAR SECRETS

foreach ($secret in $secrets.Keys)
{
    $exists =
        docker secret ls --format '{{.Name}}' |
        Where-Object { $_ -eq $secret }

    if (-not $exists)
    {
        Write-Host "🔑 Criando secret '$secret'..." -ForegroundColor Yellow

        docker secret create $secret $secrets[$secret] | Out-Null

        if ($LASTEXITCODE -ne 0)
        {
            throw "Falha ao criar o secret '$secret'."
        }

        Write-Host "✅ Secret '$secret' criado com sucesso." -ForegroundColor Green
    }
    else
    {
        Write-Host "✅ Secret '$secret' ja existe. Nenhuma acao necessaria." -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "🎉 Concluido! Docker Swarm e Secrets estao prontos para uso." -ForegroundColor Cyan