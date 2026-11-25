[CmdletBinding()]
param(
    [switch]$RemoveSourceFiles
)

# Cria os Docker Secrets e inicializa o Docker Swarm

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "Iniciando Configuracao de Docker Swarm e Secrets..." -ForegroundColor Cyan

function Invoke-Docker {
    param([Parameter(Mandatory)][string[]]$Arguments)

    & docker @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao executar: docker $($Arguments -join ' ')"
    }
}

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
    Write-Host "Docker Swarm nao esta ativo. Inicializando..." -ForegroundColor Yellow

    Invoke-Docker -Arguments @("swarm", "init")

    Write-Host "Docker Swarm inicializado com sucesso." -ForegroundColor Green
}
elseif ($swarmStatus -ne "active")
{
    throw "Docker Swarm em estado invalido: $swarmStatus"
}
else
{
    Write-Host "Docker Swarm ja esta ativo." -ForegroundColor Gray
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
    if (-not (Test-Path -LiteralPath $file -PathType Leaf))
    {
        throw "Arquivo de secret nao encontrado: $file"
    }

    if ([string]::IsNullOrWhiteSpace((Get-Content -LiteralPath $file -Raw)))
    {
        throw "Arquivo de secret vazio: $file"
    }
}

# CRIAR SECRETS

foreach ($secret in $secrets.GetEnumerator())
{
    $name = $secret.Key
    $file = $secret.Value
    $existing = @(
        docker secret ls --format '{{.Name}}' |
            Where-Object { $_ -eq $name }
    )

    if ($existing.Count -gt 0)
    {
        Write-Host "Docker Secret '$name' ja existe; arquivo nao sera lido novamente." -ForegroundColor Yellow
        continue
    }

    Write-Host "Criando Docker Secret '$name'..." -ForegroundColor Green
    Invoke-Docker -Arguments @("secret", "create", $name, $file)
}

if ($RemoveSourceFiles) {
    foreach ($file in $secrets.Values) {
        if (Test-Path -LiteralPath $file -PathType Leaf) {
            Remove-Item -LiteralPath $file -Force
            Write-Host "Arquivo removido apos criacao do secret: $file" -ForegroundColor Yellow
        }
    }
}

Write-Host "Docker Secrets disponiveis:" -ForegroundColor Green
& docker secret ls --format "table {{.Name}}\t{{.CreatedAt}}"
