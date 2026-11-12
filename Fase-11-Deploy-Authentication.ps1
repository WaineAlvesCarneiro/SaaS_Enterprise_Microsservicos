[CmdletBinding()]
param(
	[switch]$RemoveSourceFiles
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repositoryPath = $PSScriptRoot
$servicePath = Join-Path $repositoryPath "Servicos\Authentication"
$composeFile = Join-Path $servicePath "docker-compose.yml"
$dockerfile = Join-Path $servicePath "Authentication.API\Dockerfile"
$imageName = "authentication-api:local"
$networkName = "infra_net"
$stackName = "authentication-api"
$composeServiceName = "api"
$apiServiceName = "${stackName}_${composeServiceName}"

function Invoke-Docker {
	param([Parameter(Mandatory)][string[]]$Arguments)

	& docker @Arguments
	if ($LASTEXITCODE -ne 0) {
		throw "Falha ao executar: docker $($Arguments -join ' ')"
	}
}

if (-not (Test-Path -LiteralPath $composeFile -PathType Leaf)) {
	throw "docker-compose.yml não encontrado: $composeFile"
}

if (-not (Test-Path -LiteralPath $dockerfile -PathType Leaf)) {
	throw "Dockerfile não encontrado: $dockerfile"
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
	throw "Docker nao foi encontrado no PATH."
}

$composeContent = Get-Content -LiteralPath $composeFile -Raw
$legacyServicePattern = '(?m)^  authentication-api:(?=\r?$)'
$legacyServiceCount = [regex]::Matches($composeContent, $legacyServicePattern).Count
$apiServicePattern = '(?m)^  api:(?=\r?$)'
$apiServiceCount = [regex]::Matches($composeContent, $apiServicePattern).Count

if ($legacyServiceCount -eq 1 -and $apiServiceCount -eq 0) {
	$composeContent = [regex]::Replace($composeContent, $legacyServicePattern, '  api:', 1)
	Set-Content -LiteralPath $composeFile -Value $composeContent -Encoding utf8
}
elseif ($legacyServiceCount -ne 0 -or $apiServiceCount -ne 1) {
	throw "Nao foi possivel identificar unicamente o servico 'api' ou o servico legado 'authentication-api' em $composeFile."
}

& (Join-Path $repositoryPath "Fase-1-Criar-Secrets.ps1") -RemoveSourceFiles:$RemoveSourceFiles
if ($LASTEXITCODE -ne 0) {
	throw "Falha ao inicializar os Docker Secrets."
}

$swarmState = (& docker info --format '{{.Swarm.LocalNodeState}}').Trim()
if ($swarmState -ne "active") {
	throw "O Docker Swarm não está ativo."
}

$network = & docker network inspect $networkName 2>$null
if ($LASTEXITCODE -ne 0) {
	Write-Host "Criando rede overlay '$networkName'..." -ForegroundColor Yellow
	Invoke-Docker -Arguments @("network", "create", "--driver", "overlay", "--attachable", $networkName)
}

Write-Host "Construindo imagem $imageName..." -ForegroundColor Yellow
Push-Location $servicePath
try {
	Invoke-Docker -Arguments @("build", "-t", $imageName, "-f", "Authentication.API/Dockerfile", ".")

	Write-Host "Publicando stack '$stackName'..." -ForegroundColor Yellow
	Invoke-Docker -Arguments @("stack", "deploy", "--resolve-image", "never", "-c", "docker-compose.yml", $stackName)

	Write-Host "Atualizando o servico '$apiServiceName'..." -ForegroundColor Yellow
	Invoke-Docker -Arguments @("service", "update", "--force", $apiServiceName)
}
finally {
	Pop-Location
}

Write-Host "Serviços publicados no stack '$stackName':" -ForegroundColor Green
Invoke-Docker -Arguments @("stack", "services", $stackName)
