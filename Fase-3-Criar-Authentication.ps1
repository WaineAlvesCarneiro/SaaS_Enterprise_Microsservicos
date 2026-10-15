# Fase-3-Criar-Authentication.ps1

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$rootPath = $PSScriptRoot
$servicesPath = Join-Path $rootPath "Servicos"
$serviceName = "Authentication"
$servicePath = Join-Path $servicesPath $serviceName

function Invoke-DotNet {
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    & dotnet @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao executar: dotnet $($Arguments -join ' ')"
    }
}

function Get-LatestStableSdk {

    $rawSdks = & dotnet --list-sdks

    $stableSdks = @(
        $rawSdks |
        Where-Object {
            $_ -notmatch 'preview|rc'
        } |
        ForEach-Object {

            $versionText = ($_ -split '\s+')[0]

            try {
                [PSCustomObject]@{
                    Version = [Version]$versionText
                    Text    = $_
                }
            }
            catch {
            }
        } |
        Sort-Object Version -Descending
    )

    if ($stableSdks.Count -eq 0) {
        throw "Nenhum SDK estável encontrado."
    }

    return $stableSdks[0]
}

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    throw "SDK .NET não encontrado."
}

$latestSdk = Get-LatestStableSdk
$majorVersion = $latestSdk.Version.Major
$targetFramework = "net$majorVersion.0"

Write-Host "SDK detectado: $($latestSdk.Version)" -ForegroundColor Green
Write-Host "TargetFramework: $targetFramework" -ForegroundColor Green

New-Item -ItemType Directory -Force -Path $servicesPath | Out-Null
New-Item -ItemType Directory -Force -Path $servicePath | Out-Null

Push-Location $servicePath

try {

    $solutionFile = Join-Path $servicePath "$serviceName.slnx"

    if (-not (Test-Path $solutionFile)) {
        Invoke-DotNet -Arguments @(
            "new",
            "sln",
            "-n",
            $serviceName
        )
    }

    $projects = @(
        @{
            Name = "Authentication.API"
            Type = "webapi"
        },
        @{
            Name = "Authentication.Application"
            Type = "classlib"
        },
        @{
            Name = "Authentication.Domain"
            Type = "classlib"
        },
        @{
            Name = "Authentication.Infrastructure"
            Type = "classlib"
        },
        @{
            Name = "Authentication.Tests"
            Type = "xunit"
        }
    )

    foreach ($project in $projects) {

        $projectFolder = Join-Path $servicePath $project.Name

        if (-not (Test-Path $projectFolder)) {

            Invoke-DotNet -Arguments @(
                "new",
                $project.Type,
                "-n",
                $project.Name,
                "-f",
                $targetFramework
            )
        }
    }

    $projectFiles = @(
        (Join-Path $servicePath "Authentication.API\Authentication.API.csproj"),
        (Join-Path $servicePath "Authentication.Application\Authentication.Application.csproj"),
        (Join-Path $servicePath "Authentication.Domain\Authentication.Domain.csproj"),
        (Join-Path $servicePath "Authentication.Infrastructure\Authentication.Infrastructure.csproj"),
        (Join-Path $servicePath "Authentication.Tests\Authentication.Tests.csproj")
    )

    foreach ($projectFile in $projectFiles) {

        Invoke-DotNet -Arguments @(
            "sln",
            $solutionFile,
            "add",
            $projectFile
        )
    }

    $templateFiles = @(
        "Class1.cs",
        "UnitTest1.cs",
        "WeatherForecast.cs",
        "WeatherForecastController.cs",
        "Worker.cs"
    )

    Get-ChildItem `
        -Path $servicePath `
        -Recurse `
        -File |
    Where-Object {
        $_.Name -in $templateFiles
    } |
    ForEach-Object {

        Write-Host `
            "Removendo arquivo padrao: $($_.FullName)" `
            -ForegroundColor Yellow

        Remove-Item `
            -LiteralPath $_.FullName `
            -Force
    }

$apiPath = Join-Path $servicePath "Authentication.API"

$appSettings = @'
{
  "Database": {
    "Server": "",
    "Port": "",
    "Database": ""
  },

  "RabbitMQ": {
    "Host": "",
    "Port": "",
    "Username": ""
  },

  "Jwt": {
    "Issuer": "",
    "Audience": ""
  },

  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
'@

Set-Content `
    -Path (Join-Path $apiPath "appsettings.json") `
    -Value $appSettings `
    -Encoding UTF8

$appSettingsDevelopment = @'
{
  "Logging": {
    "LogLevel": {
      "Default": "Debug",
      "Microsoft.AspNetCore": "Information"
    }
  }
}
'@

Set-Content `
    -Path (Join-Path $apiPath "appsettings.Development.json") `
    -Value $appSettingsDevelopment `
    -Encoding UTF8

$appSettingsProduction = @'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
'@

Set-Content `
    -Path (Join-Path $apiPath "appsettings.Production.json") `
    -Value $appSettingsProduction `
    -Encoding UTF8

$dockerfile = @'
FROM mcr.microsoft.com/dotnet/aspnet:latest AS base

WORKDIR /app

EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:latest AS build

WORKDIR /src

COPY . .

RUN dotnet restore Authentication.API/Authentication.API.csproj

RUN dotnet publish Authentication.API/Authentication.API.csproj ^
    -c Release ^
    -o /app/publish

FROM base AS final

WORKDIR /app

COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "Authentication.API.dll"]
'@

Set-Content `
    -Path (Join-Path $apiPath "Dockerfile") `
    -Value $dockerfile `
    -Encoding UTF8

$dockerIgnore = @'
bin
obj
.vs
.git
.gitignore
Dockerfile*
docker-compose*
'@

Set-Content `
    -Path (Join-Path $servicePath ".dockerignore") `
    -Value $dockerIgnore `
    -Encoding UTF8

    Invoke-DotNet -Arguments @(
        "add",
        (Join-Path $servicePath "Authentication.Application\Authentication.Application.csproj"),
        "reference",
        (Join-Path $servicePath "Authentication.Domain\Authentication.Domain.csproj")
    )

    Invoke-DotNet -Arguments @(
        "add",
        (Join-Path $servicePath "Authentication.Infrastructure\Authentication.Infrastructure.csproj"),
        "reference",
        (Join-Path $servicePath "Authentication.Application\Authentication.Application.csproj")
    )

    Invoke-DotNet -Arguments @(
        "add",
        (Join-Path $servicePath "Authentication.Infrastructure\Authentication.Infrastructure.csproj"),
        "reference",
        (Join-Path $servicePath "Authentication.Domain\Authentication.Domain.csproj")
    )

    Invoke-DotNet -Arguments @(
        "add",
        (Join-Path $servicePath "Authentication.API\Authentication.API.csproj"),
        "reference",
        (Join-Path $servicePath "Authentication.Application\Authentication.Application.csproj")
    )

    $composeFile = Join-Path $servicePath "docker-compose.yml"

    if (-not (Test-Path $composeFile)) {

@"
services:
  authentication.api:
    build:
      context: .
      dockerfile: Authentication.API/Dockerfile

    container_name: authentication.api

    ports:
      - "5000:8080"

    networks:
      - infra_net

networks:
  infra_net:
    external: true
"@ | Set-Content -Path $composeFile -Encoding UTF8
    }

    $frameworkFile = Join-Path $servicesPath "Authentication.TargetFramework.txt"

    Set-Content `
        -Path $frameworkFile `
        -Value $targetFramework `
        -Encoding UTF8

    Write-Host "Restaurando solução..." -ForegroundColor Yellow

    Invoke-DotNet -Arguments @(
        "restore",
        $solutionFile
    )

    Write-Host "Compilando solução..." -ForegroundColor Yellow

    Invoke-DotNet -Arguments @(
        "build",
        $solutionFile
    )

    Write-Host "Fase 3 concluída com sucesso." -ForegroundColor Green
}
finally {
    Pop-Location
}