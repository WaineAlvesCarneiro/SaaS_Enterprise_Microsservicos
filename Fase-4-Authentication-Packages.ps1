# Instala os pacotes necessários da Authentication.

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

dotnet --info | Out-Null

if ($LASTEXITCODE -ne 0)
{
    throw "SDK .NET nao esta disponivel."
}

function Ensure-TestProjectSettings {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Project
    )

    [xml]$projectXml = Get-Content -LiteralPath $Project -Raw
    $propertyGroup = $projectXml.SelectSingleNode("/Project/PropertyGroup")

    if (-not $propertyGroup) {
        $propertyGroup = $projectXml.CreateElement("PropertyGroup")
        $null = $projectXml.DocumentElement.AppendChild($propertyGroup)
    }

    foreach ($setting in @{
        IsTestProject = "true"
        TestingPlatformDotnetTestSupport = "true"
    }.GetEnumerator()) {
        $node = $propertyGroup.SelectSingleNode($setting.Key)
        if (-not $node) {
            $node = $projectXml.CreateElement($setting.Key)
            $null = $propertyGroup.AppendChild($node)
        }
        $node.InnerText = $setting.Value
    }

    $projectXml.Save($Project)
}

$servicePath = Join-Path $PSScriptRoot "Servicos\Authentication"
$solutionPath = Join-Path $servicePath "Authentication.slnx"

$tfFile = Join-Path $PSScriptRoot 'Authentication.TargetFramework.txt'

if (-not (Test-Path -LiteralPath $tfFile)) {
    throw "TargetFramework nao encontrado. Execute a Fase 3 primeiro para gerar $tfFile"
}

$TargetFramework = (Get-Content -LiteralPath $tfFile -Raw).Trim()
if ($TargetFramework -notmatch '^net\d+\.0$') {
    throw "TargetFramework invalido em ${tfFile}: $TargetFramework"
}

Write-Host "TargetFramework detectado: $TargetFramework" -ForegroundColor Green

$projectPaths = @{
    API            = Join-Path $servicePath "Authentication.API\Authentication.API.csproj"
    Application    = Join-Path $servicePath "Authentication.Application\Authentication.Application.csproj"
    Domain         = Join-Path $servicePath "Authentication.Domain\Authentication.Domain.csproj"
    Infrastructure = Join-Path $servicePath "Authentication.Infrastructure\Authentication.Infrastructure.csproj"
    Tests          = Join-Path $servicePath "Authentication.Tests\Authentication.Tests.csproj"
}

foreach ($project in $projectPaths.Values) {
    if (-not (Test-Path -LiteralPath $project)) {
        throw "Projeto obrigatorio nao encontrado: $project. Execute e valide a anterior antes de executar essa Fase."
    }
}

function Invoke-DotNet {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & dotnet @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "O comando 'dotnet $($Arguments -join ' ')' falhou com o codigo $LASTEXITCODE."
    }
}

function Get-FrameworkMajor {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetFramework
    )

    $match = [regex]::Match($TargetFramework, 'net(\d+)')

    if (-not $match.Success) {
        throw "Nao foi possivel extrair a major version do TargetFramework: $TargetFramework"
    }

    return [int]$match.Groups[1].Value
}

function Get-FrameworkVersionPattern {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetFramework
    )

    $major = Get-FrameworkMajor -TargetFramework $TargetFramework
    return "$major.0.*"
}

function Ensure-Package {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Project,

        [Parameter(Mandatory = $true)]
        [string]$Package,

        [string]$Version
    )

    [xml]$projectXml = Get-Content -LiteralPath $Project -Raw

    $packageReference =
        $projectXml.SelectNodes("//PackageReference") |
        Where-Object { $_.Include -eq $Package } |
        Select-Object -First 1

    if ($packageReference -and (-not $Version -or $packageReference.Version -eq $Version)) {
        Write-Host "Pacote ja referenciado na versao esperada: $Package" -ForegroundColor Gray
        return
    }

    $arguments = @(
        "add",
        $Project,
        "package",
        $Package
    )

    if ($Version) {
        $arguments += @(
            "--version",
            $Version
        )
    }

    if ($packageReference) {
        Write-Host "Alinhando $Package para a versao $Version no projeto $(Split-Path -Leaf $Project)..." -ForegroundColor Yellow
    }
    else {
        Write-Host "Adicionando pacote $Package ao projeto $(Split-Path -Leaf $Project)..." -ForegroundColor Yellow
    }

    Invoke-DotNet -Arguments $arguments
}

function Remove-Package {
    param(
        [string]$Project,
        [string]$Package
    )

    [xml]$projectXml = Get-Content -LiteralPath $Project -Raw

    $packageReference =
        $projectXml.SelectNodes("//PackageReference") |
        Where-Object { $_.Include -eq $Package } |
        Select-Object -First 1

    if ($packageReference)
    {
        Write-Host "Removendo pacote $Package..." -ForegroundColor Yellow

        Invoke-DotNet -Arguments @(
            "remove",
            $Project,
            "package",
            $Package
        )
    }
}

function Ensure-DotNetEf {

    if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {

        $localDotnet = Join-Path $HOME '.dotnet'
        $localDotnetExe = Join-Path $localDotnet 'dotnet.exe'

        if (Test-Path $localDotnetExe) {
            $env:PATH = "$([System.IO.Path]::GetFullPath($localDotnet));" + $env:PATH
            Write-Host "Adicionado dotnet local ao PATH da sessao: $localDotnet" -ForegroundColor Yellow
        }
    }

    $currentPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"

    try {
        $versionOutput = & dotnet ef --version 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $currentPreference
    }

    $efMajor = Get-FrameworkMajor -TargetFramework $TargetFramework
    $efPackageVersion = "$efMajor.0.*"

    if ($exitCode -ne 0) {

        Write-Host "dotnet-ef nao encontrado. Instalando ferramenta global dotnet-ef na versao $efPackageVersion..." -ForegroundColor Yellow

        Invoke-DotNet -Arguments @(
            "tool",
            "install",
            "--global",
            "dotnet-ef",
            "--version",
            $efPackageVersion
        )

        $versionOutput = & dotnet ef --version 2>&1
        $exitCode = $LASTEXITCODE
    }

    if ($exitCode -ne 0) {
        throw "Nao foi possivel executar 'dotnet ef --version' apos tentativa de instalacao. Saida: $versionOutput"
    }

    $versionText = ($versionOutput -join ' ')
    $versionMatch = [regex]::Match($versionText, '(\d+\.\d+\.\S+)')

    if (-not $versionMatch.Success) {
        throw "Nao foi possivel obter a versao do dotnet-ef. Saida: $versionText"
    }

    $installedEfVersion = $versionMatch.Groups[1].Value

    $installedMajor =
        [int](
            ([regex]::Match($installedEfVersion,'^(\d+)')).Groups[1].Value
        )

    if ($installedMajor -ne $efMajor)
    {
        Write-Host "Atualizando dotnet-ef para a major version correta..." -ForegroundColor Yellow

        Invoke-DotNet -Arguments @(
            "tool",
            "update",
            "--global",
            "dotnet-ef",
            "--version",
            $efPackageVersion
        )

        $currentPreference = $ErrorActionPreference
        $ErrorActionPreference = "Continue"

        try {
            $versionOutput = & dotnet ef --version 2>&1
            $exitCode = $LASTEXITCODE
        }
        finally {
            $ErrorActionPreference = $currentPreference
        }

        if ($exitCode -ne 0) {
            throw "Nao foi possivel executar 'dotnet ef --version' apos a atualizacao. Saida: $versionOutput"
        }

        $versionText = ($versionOutput -join ' ')

        $versionMatch = [regex]::Match(
            $versionText,
            '(\d+\.\d+\.\S+)'
        )

        if (-not $versionMatch.Success)
        {
            throw "Nao foi possivel obter a versao do dotnet-ef."
        }

        $installedEfVersion = $versionMatch.Groups[1].Value

        $installedMajor =
            [int](
                ([regex]::Match($installedEfVersion,'^(\d+)')).Groups[1].Value
            )

        if ($installedMajor -ne $efMajor)
        {
            throw "Nao foi possivel alinhar a major version do dotnet-ef."
        }
    }

    Write-Host "dotnet-ef alinhado para a major version $efMajor" -ForegroundColor Green
    Write-Host "dotnet-ef validado: $installedEfVersion" -ForegroundColor Green

    return [PSCustomObject]@{
        ToolVersion    = $installedEfVersion
        PackageVersion = $installedEfVersion
    }
}

if (-not (Test-Path $solutionPath)) {
    throw "Solution nao encontrada: $solutionPath. Execute e valide a Fase anterior antes da Fase anterior."
}

if ([System.IO.Path]::GetExtension($solutionPath) -ne ".slnx")
{
    throw "Solution invalida. Esperado .slnx."
}

Write-Host "Solution detectada: $solutionPath" -ForegroundColor Green

[xml]$testProjectXml = Get-Content $projectPaths.Tests -Raw

$usingNode = $testProjectXml.SelectSingleNode("//ItemGroup/Using[@Include='Xunit']")

if ($usingNode) {

    $parentGroup = $usingNode.ParentNode
    $null = $parentGroup.RemoveChild($usingNode)

    if (-not $parentGroup.HasChildNodes -or ($parentGroup.ChildNodes.Count -eq 0)) {
        $null = $parentGroup.ParentNode.RemoveChild($parentGroup)
    }

    $testProjectXml.Save($projectPaths.Tests)

    Write-Host "Using Xunit removido do projeto de testes." -ForegroundColor Yellow
}

Write-Host "Iniciando Fase pacotes da Authentication..." -ForegroundColor Cyan

Remove-Package -Project $projectPaths.Tests -Package "xunit"
Remove-Package -Project $projectPaths.Infrastructure -Package "System.Security.Cryptography.Pkcs"
Ensure-TestProjectSettings -Project $projectPaths.Tests

$efInfo = Ensure-DotNetEf

$efPackageVersion = $efInfo.PackageVersion

$aspNetPackageVersion = Get-FrameworkVersionPattern -TargetFramework $TargetFramework

Write-Host "Versao ASP.NET Core selecionada: $aspNetPackageVersion" -ForegroundColor Green
Write-Host "System.Security.Cryptography.Pkcs sera resolvido pela dependencia compativel do EF Core $efPackageVersion." -ForegroundColor Green

$packages = @(
    @{ Project = $projectPaths.Application; Package = "MediatR" },
    @{ Project = $projectPaths.Application; Package = "FluentValidation" },
    @{ Project = $projectPaths.Application; Package = "FluentValidation.DependencyInjectionExtensions" },

    @{ Project = $projectPaths.Infrastructure; Package = "Microsoft.EntityFrameworkCore.SqlServer"; Version = $efPackageVersion },
    @{ Project = $projectPaths.Infrastructure; Package = "Microsoft.EntityFrameworkCore.Design"; Version = $efPackageVersion },
    @{ Project = $projectPaths.Infrastructure; Package = "BCrypt.Net-Next" },
    @{ Project = $projectPaths.Infrastructure; Package = "RabbitMQ.Client" },
    @{ Project = $projectPaths.Infrastructure; Package = "System.IdentityModel.Tokens.Jwt" },
    @{ Project = $projectPaths.Infrastructure; Package = "Microsoft.AspNetCore.Authentication.JwtBearer"; Version = $aspNetPackageVersion },
    @{ Project = $projectPaths.Infrastructure; Package = "Microsoft.Extensions.Hosting"; Version = $aspNetPackageVersion },

    @{ Project = $projectPaths.API; Package = "Microsoft.AspNetCore.Authentication.JwtBearer"; Version = $aspNetPackageVersion },
    @{ Project = $projectPaths.API; Package = "Microsoft.AspNetCore.OpenApi"; Version = $aspNetPackageVersion },
    @{ Project = $projectPaths.API; Package = "Swashbuckle.AspNetCore"; Version = $aspNetPackageVersion },
    @{ Project = $projectPaths.API; Package = "Microsoft.Extensions.Diagnostics.HealthChecks.EntityFrameworkCore"; Version = $efPackageVersion },

    @{ Project = $projectPaths.Tests; Package = "Microsoft.NET.Test.Sdk" },
    @{ Project = $projectPaths.Tests; Package = "xunit.v3" },
    @{ Project = $projectPaths.Tests; Package = "xunit.runner.visualstudio" },
    @{ Project = $projectPaths.Tests; Package = "FluentAssertions" },
    @{ Project = $projectPaths.Tests; Package = "Moq" },
    @{ Project = $projectPaths.Tests; Package = "Microsoft.EntityFrameworkCore.InMemory"; Version = $efPackageVersion }
)

foreach ($package in $packages) {
    if ($package.ContainsKey("Version")) {
        Ensure-Package -Project $package.Project -Package $package.Package -Version $package.Version
    }
    else {
        Ensure-Package -Project $package.Project -Package $package.Package
    }
}

Write-Host "Essa Fase foi concluida com sucesso." -ForegroundColor Green