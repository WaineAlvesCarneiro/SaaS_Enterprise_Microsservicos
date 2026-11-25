# Cria a solução e os projetos do microsserviço Authentication

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

function Ensure-ProjectReference {

    param(
        [string]$Project,
        [string]$Reference
    )

    $refs = dotnet list $Project reference

    if ($LASTEXITCODE -ne 0)
    {
        throw "Falha ao listar referencias do projeto: $Project"
    }

    $referenceName = [System.IO.Path]::GetFileName($Reference)

    if ($refs -notmatch [regex]::Escape($referenceName))
    {
        Invoke-DotNet -Arguments @(
            "add",
            $Project,
            "reference",
            $Reference
        )
    }
}

dotnet --info | Out-Null

if ($LASTEXITCODE -ne 0)
{
    throw "SDK .NET nao esta disponivel."
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
        throw "Nenhum SDK estavel encontrado."
    }

    return $stableSdks[0]
}

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    throw "SDK .NET nao encontrado."
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
            $serviceName,
            "--format",
            "slnx"
        )
    }
    if (-not (Test-Path $solutionFile))
    {
        throw "Falha ao criar a solution."
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

    $composeProjectPath = Join-Path $servicePath "docker-compose.dcproj"
    $composeProject = @'
<Project Sdk="Microsoft.Docker.Sdk">
  <PropertyGroup Label="Globals">
    <ProjectVersion>2.1</ProjectVersion>
    <DockerTargetOS>Linux</DockerTargetOS>
    <DockerLaunchAction>LaunchBrowser</DockerLaunchAction>
    <DockerLaunchUrl>http://localhost:8080/swagger</DockerLaunchUrl>
    <DockerServiceName>api</DockerServiceName>
  </PropertyGroup>
  <ItemGroup>
    <None Include="docker-compose.yml" />
    <None Include="docker-compose.override.yml" />
  </ItemGroup>
</Project>
'@
    Set-Content -LiteralPath $composeProjectPath -Value $composeProject -Encoding UTF8

    $composePropertiesPath = Join-Path $servicePath "Properties"
    New-Item -ItemType Directory -Force -Path $composePropertiesPath | Out-Null
    $composeLaunchSettings = @'
{
  "$schema": "https://json.schemastore.org/launchsettings.json",
  "profiles": {
    "Docker Compose": {
      "commandName": "DockerCompose",
      "commandVersion": "1.0",
      "serviceActions": {
        "api": "StartDebugging"
      }
    }
  }
}
'@
    Set-Content -LiteralPath (Join-Path $composePropertiesPath "launchSettings.json") -Value $composeLaunchSettings -Encoding UTF8

    $projectFiles = @(
        (Join-Path $servicePath "Authentication.API\Authentication.API.csproj"),
        (Join-Path $servicePath "Authentication.Application\Authentication.Application.csproj"),
        (Join-Path $servicePath "Authentication.Domain\Authentication.Domain.csproj"),
        (Join-Path $servicePath "Authentication.Infrastructure\Authentication.Infrastructure.csproj"),
        (Join-Path $servicePath "Authentication.Tests\Authentication.Tests.csproj")
    )

    foreach ($projectFile in $projectFiles) {

        $projectName = [System.IO.Path]::GetFileNameWithoutExtension($projectFile)

        $alreadyAdded = (& dotnet sln $solutionFile list) | Where-Object { $_ -match [regex]::Escape($projectName) }

        if (-not $alreadyAdded) {

            Invoke-DotNet -Arguments @(
                "sln",
                $solutionFile,
                "add",
                $projectFile
            )
        }
    }

    $templateFiles = @(
        "Class1.cs",
        "UnitTest1.cs",
        "WeatherForecast.cs",
        "WeatherForecastController.cs",
        "Worker.cs"
    )

    Get-ChildItem -Path $servicePath -Recurse -File | Where-Object { $_.Name -in $templateFiles } | ForEach-Object {
        Write-Host "Removendo arquivo padrao: $($_.FullName)" -ForegroundColor Yellow
        Remove-Item -LiteralPath $_.FullName -Force
    }

    $apiPath = Join-Path $servicePath "Authentication.API"

$appSettings = @'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },

  "AllowedHosts": "*",

  "Database": {
    "Server": "",
    "Port": 1433,
    "Database": "Db_Authentication"
  },

  "RabbitMQ": {
    "Host": "",
    "Port": 5672,
    "Username": ""
  },

  "Jwt": {
    "Issuer": "Authentication",
    "Audience": "SaaSEnterprise",
    "ExpireMinutes": 60,
    "RefreshTokenDays": 30
  },

  "HealthChecks": {
    "Enabled": true,
    "Path": "/health"
  }
}
'@

    Set-Content -Path (Join-Path $apiPath "appsettings.json") -Value $appSettings -Encoding UTF8

$appSettingsDevelopment = @'
{
  "Database": {
    "Server": "localhost"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Debug",
      "Microsoft.AspNetCore": "Information"
    }
  }
}
'@

    Set-Content -Path (Join-Path $apiPath "appsettings.Development.json") -Value $appSettingsDevelopment -Encoding UTF8

$appSettingsProduction = @'
{
  "Database": {
    "Server": "sqlserver2022",
    "Port": 1433,
    "Database": "Db_Authentication"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
'@

    Set-Content -Path (Join-Path $apiPath "appsettings.Production.json") -Value $appSettingsProduction -Encoding UTF8

$dockerfile = @"
FROM mcr.microsoft.com/dotnet/aspnet:$majorVersion.0 AS base
WORKDIR /app
EXPOSE 8080
FROM mcr.microsoft.com/dotnet/sdk:$majorVersion.0 AS development
WORKDIR /src
EXPOSE 8080
ENTRYPOINT ["dotnet", "watch", "--project", "Authentication.API/Authentication.API.csproj", "run", "--no-launch-profile", "--urls", "http://0.0.0.0:8080"]
FROM mcr.microsoft.com/dotnet/sdk:$majorVersion.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore Authentication.API/Authentication.API.csproj
RUN dotnet publish Authentication.API/Authentication.API.csproj -c Release -o /app/publish
FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Authentication.API.dll"]

"@

    Set-Content -Path (Join-Path $apiPath "Dockerfile") -Value $dockerfile -Encoding UTF8

$dockerIgnore = @'
bin
obj
.vs
.git
.gitignore
Dockerfile*
docker-compose*
'@

    Set-Content -Path (Join-Path $servicePath ".dockerignore") -Value $dockerIgnore -Encoding UTF8

    Ensure-ProjectReference `
        -Project (Join-Path $servicePath "Authentication.Application\Authentication.Application.csproj") `
        -Reference (Join-Path $servicePath "Authentication.Domain\Authentication.Domain.csproj")

    Ensure-ProjectReference `
        -Project (Join-Path $servicePath "Authentication.Infrastructure\Authentication.Infrastructure.csproj") `
        -Reference (Join-Path $servicePath "Authentication.Application\Authentication.Application.csproj")

    Ensure-ProjectReference `
        -Project (Join-Path $servicePath "Authentication.Infrastructure\Authentication.Infrastructure.csproj") `
        -Reference (Join-Path $servicePath "Authentication.Domain\Authentication.Domain.csproj")

    Ensure-ProjectReference `
        -Project (Join-Path $servicePath "Authentication.API\Authentication.API.csproj") `
        -Reference (Join-Path $servicePath "Authentication.Application\Authentication.Application.csproj")

    Ensure-ProjectReference `
        -Project (Join-Path $servicePath "Authentication.API\Authentication.API.csproj") `
        -Reference (Join-Path $servicePath "Authentication.Infrastructure\Authentication.Infrastructure.csproj")

    Ensure-ProjectReference `
        -Project (Join-Path $servicePath "Authentication.Tests\Authentication.Tests.csproj") `
        -Reference (Join-Path $servicePath "Authentication.Application\Authentication.Application.csproj")

    $composeFile = Join-Path $servicePath "docker-compose.yml"
    $composeOverrideFile = Join-Path $servicePath "docker-compose.override.yml"
    $infrastructureConfiguration = @{}
    $infrastructureFile = Join-Path $rootPath ".env.base"
    if (Test-Path -LiteralPath $infrastructureFile) {
        Get-Content -LiteralPath $infrastructureFile | ForEach-Object {
            if ($_ -match '^(.*?)=(.*)$') {
                $infrastructureConfiguration[$matches[1].Trim()] = $matches[2].Trim()
            }
        }
    }

    $composeNetworkName = if ($infrastructureConfiguration.ContainsKey("DOCKER_NETWORK") -and $infrastructureConfiguration["DOCKER_NETWORK"]) { $infrastructureConfiguration["DOCKER_NETWORK"] } else { "infra_net" }
    $sqlContainerName = if ($infrastructureConfiguration.ContainsKey("SQL_CONTAINER") -and $infrastructureConfiguration["SQL_CONTAINER"]) { $infrastructureConfiguration["SQL_CONTAINER"] } else { "sqlserver2022" }
    $rabbitContainerName = if ($infrastructureConfiguration.ContainsKey("RABBIT_CONTAINER") -and $infrastructureConfiguration["RABBIT_CONTAINER"]) { $infrastructureConfiguration["RABBIT_CONTAINER"] } else { "rabbitmq" }
    $rabbitUsername = if ($infrastructureConfiguration.ContainsKey("SPRING_RABBITMQ_USERNAME") -and $infrastructureConfiguration["SPRING_RABBITMQ_USERNAME"]) { $infrastructureConfiguration["SPRING_RABBITMQ_USERNAME"] } else { "admin_geral" }

    $compose = @'
services:
  api:
    image: authentication-api:local
    environment:
      ASPNETCORE_ENVIRONMENT: Production
      Database__Server: "__SQL_CONTAINER__"
    ports:
      - "8080:8080"
    networks:
      - __DOCKER_NETWORK__
    secrets:
      - sql_sa_password
      - rabbitmq_password
      - jwt_key

secrets:
  sql_sa_password:
    external: true
  rabbitmq_password:
    external: true
  jwt_key:
    external: true

networks:
  __DOCKER_NETWORK__:
    external: true
'@
    $compose = $compose.Replace("__DOCKER_NETWORK__", $composeNetworkName)
    $compose = $compose.Replace("__SQL_CONTAINER__", $sqlContainerName)
    Set-Content -LiteralPath $composeFile -Value $compose -Encoding UTF8

    $composeOverride = @'
services:
  api:
    build:
      context: .
      dockerfile: Authentication.API/Dockerfile
      target: development
    environment:
      ASPNETCORE_ENVIRONMENT: Development
      ASPNETCORE_URLS: http://+:8080
      Database__Server: "__SQL_CONTAINER__"
      Database__Port: 1433
      Database__Database: Db_Authentication
      RabbitMQ__Host: "__RABBIT_CONTAINER__"
      RabbitMQ__Port: 5672
      RabbitMQ__Username: "__RABBIT_USERNAME__"
      DOTNET_USE_POLLING_FILE_WATCHER: "1"
    volumes:
      - .:/src
      - api_bin:/src/Authentication.API/bin
      - api_obj:/src/Authentication.API/obj
      - application_bin:/src/Authentication.Application/bin
      - application_obj:/src/Authentication.Application/obj
      - domain_bin:/src/Authentication.Domain/bin
      - domain_obj:/src/Authentication.Domain/obj
      - infrastructure_bin:/src/Authentication.Infrastructure/bin
      - infrastructure_obj:/src/Authentication.Infrastructure/obj
      - nuget_packages:/root/.nuget/packages

secrets:
  sql_sa_password:
    file: ../../secrets_sql_sa_password.txt
    external: false
  rabbitmq_password:
    file: ../../secrets_rabbitmq_password.txt
    external: false
  jwt_key:
    file: ../../secrets_jwt_key.txt
    external: false

volumes:
  api_bin:
  api_obj:
  application_bin:
  application_obj:
  domain_bin:
  domain_obj:
  infrastructure_bin:
  infrastructure_obj:
  nuget_packages:
'@
    $composeOverride = $composeOverride.Replace("__SQL_CONTAINER__", $sqlContainerName)
    $composeOverride = $composeOverride.Replace("__RABBIT_CONTAINER__", $rabbitContainerName)
    $composeOverride = $composeOverride.Replace("__RABBIT_USERNAME__", $rabbitUsername)
    Set-Content -LiteralPath $composeOverrideFile -Value $composeOverride -Encoding UTF8

    $frameworkFile = Join-Path $rootPath "Authentication.TargetFramework.txt"

    Set-Content -Path $frameworkFile -Value $targetFramework -Encoding UTF8

    $globalJsonPath = Join-Path $rootPath "global.json"
    if (-not (Test-Path -LiteralPath $globalJsonPath)) {
        @'
{
  "test": {
    "runner": "Microsoft.Testing.Platform"
  }
}
'@ | Set-Content -Path $globalJsonPath -Encoding UTF8
    }
 
    Write-Host "Restaurando solucao..." -ForegroundColor Yellow

    Invoke-DotNet -Arguments @(
        "restore",
        $solutionFile
    )

    Write-Host "Compilando solucao..." -ForegroundColor Yellow

    Invoke-DotNet -Arguments @(
        "build",
        $solutionFile
    )

    Write-Host "Essa Fase foi concluida com sucesso." -ForegroundColor Green
}
finally {
    Pop-Location
}