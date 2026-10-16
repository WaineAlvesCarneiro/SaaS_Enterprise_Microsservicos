# Cria as entidades e abstrações do Core da Authentication, sem persistência.

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$rootPath = Join-Path $PSScriptRoot "Servicos\Authentication"
$solutionPath = Join-Path $rootPath "Authentication.slnx"

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

function Test-ProjectReference {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FromProject,
        [Parameter(Mandatory = $true)]
        [string]$ToProject
    )

    [xml]$projectXml = Get-Content -LiteralPath $FromProject -Raw
    $targetPath = [System.IO.Path]::GetFullPath($ToProject)

    foreach ($reference in $projectXml.SelectNodes("//ProjectReference")) {
        if (-not $reference.Include) {
            continue
        }

        $referencedPath = [System.IO.Path]::GetFullPath(
            (Join-Path (Split-Path -Parent $FromProject) $reference.Include)
        )
        if ([string]::Equals($referencedPath, $targetPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    throw "O comando 'dotnet' nao foi encontrado no PATH. Instale o SDK .NET (versão estável detectada automaticamente) antes de executar esta fase."
}

if (-not (Test-Path $solutionPath)) {
    throw "Solution nao encontrada: $solutionPath. Execute e valide as fases 3 e 4 antes da Fase 5."
}

$projectPaths = @{
    API            = Join-Path $rootPath "Authentication.API\Authentication.API.csproj"
    Application    = Join-Path $rootPath "Authentication.Application\Authentication.Application.csproj"
    Domain         = Join-Path $rootPath "Authentication.Domain\Authentication.Domain.csproj"
    Infrastructure = Join-Path $rootPath "Authentication.Infrastructure\Authentication.Infrastructure.csproj"
    Tests          = Join-Path $rootPath "Authentication.Tests\Authentication.Tests.csproj"
}

foreach ($project in $projectPaths.Values) {
    if (-not (Test-Path -LiteralPath $project)) {
        throw "Projeto obrigatorio nao encontrado: $project. Execute e valide as fases 3 e 4 antes da Fase 5."
    }
}

if (-not (Test-ProjectReference -FromProject $projectPaths.Application -ToProject $projectPaths.Domain)) {
    throw "Referencia obrigatoria ausente: Authentication.Application deve referenciar Authentication.Domain."
}
if (Test-ProjectReference -FromProject $projectPaths.Application -ToProject $projectPaths.Infrastructure) {
    throw "Violacao arquitetural: Authentication.Application nao pode referenciar Authentication.Infrastructure."
}
[xml]$domainXml = Get-Content -LiteralPath $projectPaths.Domain -Raw
if ($domainXml.SelectNodes("//ProjectReference").Count -gt 0) {
    throw "Violacao arquitetural: Authentication.Domain nao pode referenciar outros projetos."
}
if (-not (Test-ProjectReference -FromProject $projectPaths.Infrastructure -ToProject $projectPaths.Application) -or
    -not (Test-ProjectReference -FromProject $projectPaths.Infrastructure -ToProject $projectPaths.Domain)) {
    throw "Authentication.Infrastructure deve referenciar Authentication.Application e Authentication.Domain."
}
if (-not (Test-ProjectReference -FromProject $projectPaths.API -ToProject $projectPaths.Application) -or
    -not (Test-ProjectReference -FromProject $projectPaths.API -ToProject $projectPaths.Infrastructure)) {
    throw "Authentication.API deve referenciar Authentication.Application e Authentication.Infrastructure."
}
if (-not (Test-ProjectReference -FromProject $projectPaths.Tests -ToProject $projectPaths.Application)) {
    throw "Authentication.Tests deve referenciar Authentication.Application."
}

[xml]$applicationXml = Get-Content -LiteralPath $projectPaths.Application -Raw
$applicationPackages = @($applicationXml.SelectNodes("//PackageReference") | ForEach-Object { $_.Include })
foreach ($package in @("MediatR", "FluentValidation")) {
    if ($package -notin $applicationPackages) {
        throw "Pacote obrigatorio ausente em Authentication.Application: $package. Execute e valide a Fase 4 antes da Fase 5."
    }
}

$coreDirectories = @(
    (Join-Path $rootPath "Authentication.Domain\Entities"),
    (Join-Path $rootPath "Authentication.Application\Interfaces"),
    (Join-Path $rootPath "Authentication.Application\Behaviors")
)

foreach ($directory in $coreDirectories) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
}

Write-Host "Iniciando Fase 5: Core da Authentication..." -ForegroundColor Cyan

$coreFiles = @()

# USER ENTITY

$userEntity = @'
namespace Authentication.Domain.Entities;

public class User
{
    public Guid Id { get; set; }

    public Guid? TenantId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string Email { get; set; } = string.Empty;

    public string PasswordHash { get; set; } = string.Empty;

    public bool Active { get; set; } = true;

    public bool FirstAccess { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    public DateTime? LastLoginAt { get; set; }

    public Guid RoleId { get; set; }

    public Role? Role { get; set; }
}
'@

$coreFiles += @{
    Path = Join-Path $rootPath "Authentication.Domain\Entities\User.cs"
    Content = $userEntity
}

# ROLE ENTITY

$roleEntity = @'
namespace Authentication.Domain.Entities;

public class Role
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public ICollection<User> Users { get; set; } = new List<User>();

    public ICollection<Permission> Permissions { get; set; } = new List<Permission>();
}
'@

$coreFiles += @{
    Path = Join-Path $rootPath "Authentication.Domain\Entities\Role.cs"
    Content = $roleEntity
}

# PERMISSION ENTITY

$permissionEntity = @'
namespace Authentication.Domain.Entities;

public class Permission
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public ICollection<Role> Roles { get; set; } = new List<Role>();
}
'@

$coreFiles += @{
    Path = Join-Path $rootPath "Authentication.Domain\Entities\Permission.cs"
    Content = $permissionEntity
}

# REFRESH TOKEN ENTITY

$refreshTokenEntity = @'
namespace Authentication.Domain.Entities;

public class RefreshToken
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public string Token { get; set; } = string.Empty;

    public DateTime ExpiresAt { get; set; }

    public bool Revoked { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? RevokedAt { get; set; }

    public User? User { get; set; }
}
'@

$coreFiles += @{
    Path = Join-Path $rootPath "Authentication.Domain\Entities\RefreshToken.cs"
    Content = $refreshTokenEntity
}

# TOKEN SERVICE INTERFACE

$tokenInterface = @'
using Authentication.Domain.Entities;

namespace Authentication.Application.Interfaces;

public interface ITokenService
{
    string GenerateToken(User user);
}
'@

$coreFiles += @{
    Path = Join-Path $rootPath "Authentication.Application\Interfaces\ITokenService.cs"
    Content = $tokenInterface
}

# PASSWORD HASHER INTERFACE

$passwordHasherInterface = @'
namespace Authentication.Application.Interfaces;

public interface IPasswordHasher
{
    string Hash(string password);

    bool Verify(string password, string passwordHash);
}
'@

$coreFiles += @{
    Path = Join-Path $rootPath "Authentication.Application\Interfaces\IPasswordHasher.cs"
    Content = $passwordHasherInterface
}

# VALIDATION BEHAVIOR

$validationBehavior = @'
using FluentValidation;
using MediatR;

namespace Authentication.Application.Behaviors;

public sealed class ValidationBehavior<TRequest, TResponse>
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    private readonly IEnumerable<IValidator<TRequest>>
        _validators;

    public ValidationBehavior(
        IEnumerable<IValidator<TRequest>> validators)
    {
        _validators = validators;
    }

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        if (!_validators.Any())
        {
            return await next(cancellationToken);
        }

        var failures = new List<FluentValidation.Results.ValidationFailure>();

        foreach (var validator in _validators)
        {
            var context =
                new ValidationContext<TRequest>(request);

            var result =
                await validator.ValidateAsync(
                    context,
                    cancellationToken);

            failures.AddRange(
                result.Errors.Where(x => x != null)
            );
        }

        if (failures.Count > 0)
        {
            throw new ValidationException(failures);
        }

        return await next(cancellationToken);
    }
}
'@

$coreFiles += @{
    Path = Join-Path $rootPath "Authentication.Application\Behaviors\ValidationBehavior.cs"
    Content = $validationBehavior
}

foreach ($file in $coreFiles) {
    if (-not (Test-Path -LiteralPath $file.Path)) {
        continue
    }

    $existingContent = (Get-Content -LiteralPath $file.Path -Raw).Replace("`r`n", "`n").TrimEnd()
    $expectedContent = $file.Content.Replace("`r`n", "`n").TrimEnd()
    if ($existingContent -cne $expectedContent) {
        throw "Arquivo ja existe com conteudo diferente e nao sera sobrescrito: $($file.Path)"
    }
}

foreach ($file in $coreFiles) {
    if (Test-Path -LiteralPath $file.Path) {
        Write-Host "Arquivo existente e validado: $($file.Path)" -ForegroundColor Gray
        continue
    }

    Set-Content -LiteralPath $file.Path -Value $file.Content -Encoding utf8
    Write-Host "Arquivo criado: $($file.Path)" -ForegroundColor Green
}

# BUILD

Write-Host ""
Write-Host "Validando build da solution Authentication..." -ForegroundColor Yellow

Invoke-DotNet -Arguments @("build", $solutionPath)

Write-Host "Fase 5 concluida: entidades e abstracoes do Core criadas; build validado." -ForegroundColor Green