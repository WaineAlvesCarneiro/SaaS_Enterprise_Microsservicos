# Cria a camada de persistência da Authentication.

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$rootPath = Join-Path $PSScriptRoot "Servicos\Authentication"
$solutionPath = Join-Path $rootPath "Authentication.slnx"
$infrastructureProject = Join-Path $rootPath "Authentication.Infrastructure\Authentication.Infrastructure.csproj"

function Invoke-DotNet {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $currentPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"

    try {
        & dotnet @Arguments
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $currentPreference
    }

    if ($exitCode -ne 0) {
        throw "O comando 'dotnet $($Arguments -join ' ')' falhou com o codigo $exitCode."
    }
}

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    throw "O comando 'dotnet' nao foi encontrado no PATH. Instale o SDK .NET (versão estável detectada automaticamente) antes de executar esta fase."
}

if (-not (Test-Path $solutionPath)) {
    throw "Solution nao encontrada: $solutionPath. Execute e valide as fases anteriores antes da Fase 6."
}

if (-not (Test-Path -LiteralPath $infrastructureProject)) {
    throw "Projeto Infrastructure nao encontrado: $infrastructureProject. Execute e valide as fases anteriores antes da Fase 6."
}

$entityPaths = @(
    (Join-Path $rootPath "Authentication.Domain\Entities\User.cs"),
    (Join-Path $rootPath "Authentication.Domain\Entities\Role.cs"),
    (Join-Path $rootPath "Authentication.Domain\Entities\RefreshToken.cs")
)
foreach ($entityPath in $entityPaths) {
    if (-not (Test-Path -LiteralPath $entityPath)) {
        throw "Entidade obrigatoria nao encontrada: $entityPath. Execute e valide a Fase 5 antes da Fase 6."
    }
}

[xml]$infrastructureXml = Get-Content -LiteralPath $infrastructureProject -Raw
$efPackages = @($infrastructureXml.SelectNodes("//PackageReference") | Where-Object {
    $_.Include -in @("Microsoft.EntityFrameworkCore.Design", "Microsoft.EntityFrameworkCore.SqlServer")
})
$designPackage = $efPackages | Where-Object { $_.Include -eq "Microsoft.EntityFrameworkCore.Design" } | Select-Object -First 1
$sqlServerPackage = $efPackages | Where-Object { $_.Include -eq "Microsoft.EntityFrameworkCore.SqlServer" } | Select-Object -First 1
if (-not $designPackage -or -not $sqlServerPackage) {
    throw "Os pacotes Microsoft.EntityFrameworkCore.Design e Microsoft.EntityFrameworkCore.SqlServer sao obrigatorios. Execute e valide a Fase 4."
}
if ($designPackage.Version -ne $sqlServerPackage.Version) {
    throw "As versoes de EF Core Design ($($designPackage.Version)) e SqlServer ($($sqlServerPackage.Version)) precisam ser iguais. Corrija a Fase 4 antes da Fase 6."
}

$currentPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
try {
    $efVersionOutput = & dotnet ef --version 2>&1
    $efExitCode = $LASTEXITCODE
}
finally {
    $ErrorActionPreference = $currentPreference
}
if ($efExitCode -ne 0) {
    throw "A ferramenta 'dotnet-ef' nao esta disponivel. Instale e valide a versao .NET (detecção automática da versão estável mais recente) na Fase 4."
}
$efVersionText = $efVersionOutput -join " "
$efVersionMatch = [regex]::Match($efVersionText, '\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?')
if (-not $efVersionMatch.Success) {
    throw "Nao foi possivel identificar a versao do dotnet-ef: $efVersionText"
}
if ($efVersionMatch.Value -notmatch '^11\.0\.0-preview\.') {
    throw "Versao do dotnet-ef incompatível: '$($efVersionMatch.Value)'. A Fase 4 requer .NET (detecção automática da versão estável mais recente)."
}
if ($designPackage.Version -notmatch '^11\.0\.0-preview\.') {
    throw "Microsoft.EntityFrameworkCore.Design esta na versao '$($designPackage.Version)', mas dotnet-ef e .NET (versão estável detectada automaticamente) preview. Alinhe os pacotes EF Core na Fase 4 antes de executar a Fase 6."
}
if ($designPackage.Version -ne $efVersionMatch.Value) {
    throw "Versoes incompatíveis: dotnet-ef $($efVersionMatch.Value), EF Core Design $($designPackage.Version). Alinhe-as na Fase 4 antes de executar a Fase 6."
}

Write-Host "Iniciando Fase 6: persistencia da Authentication..." -ForegroundColor Cyan

# =============================================================================
# PASTAS
# =============================================================================

$folders = @(
    (Join-Path $rootPath "Authentication.Infrastructure\Persistence\Configurations"),
    (Join-Path $rootPath "Authentication.Infrastructure\Persistence\DesignTime"),
    (Join-Path $rootPath "Authentication.Infrastructure\Persistence\Extensions")
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Force -Path $folder | Out-Null
}

$generatedFiles = @()

# =============================================================================
# USER CONFIGURATION
# =============================================================================

$userConfiguration = @'
using Authentication.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Authentication.Infrastructure.Persistence.Configurations;

public sealed class UserConfiguration
    : IEntityTypeConfiguration<User>
{
    public void Configure(
        EntityTypeBuilder<User> builder)
    {
        builder.ToTable("Users");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Name)
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(x => x.Email)
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(x => x.PasswordHash)
            .HasMaxLength(500)
            .IsRequired();

        builder.Property(x => x.Active)
            .HasDefaultValue(true);

        builder.Property(x => x.FirstAccess)
            .HasDefaultValue(true);

        builder.HasIndex(x => x.Email)
            .IsUnique();

        builder.HasOne(x => x.Role)
            .WithMany(x => x.Users)
            .HasForeignKey(x => x.RoleId)
            .IsRequired()
            .OnDelete(DeleteBehavior.Restrict);
    }
}
'@

$generatedFiles += @{
    Path = Join-Path $rootPath "Authentication.Infrastructure\Persistence\Configurations\UserConfiguration.cs"
    Content = $userConfiguration
}

# =============================================================================
# ROLE CONFIGURATION
# =============================================================================

$roleConfiguration = @'
using Authentication.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Authentication.Infrastructure.Persistence.Configurations;

public sealed class RoleConfiguration
    : IEntityTypeConfiguration<Role>
{
    public void Configure(
        EntityTypeBuilder<Role> builder)
    {
        builder.ToTable("Roles");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Name)
            .HasMaxLength(100)
            .IsRequired();

        builder.HasIndex(x => x.Name)
            .IsUnique();

        builder.HasMany(x => x.Users)
            .WithOne(x => x.Role)
            .HasForeignKey(x => x.RoleId)
            .IsRequired()
            .OnDelete(DeleteBehavior.Restrict);
    }
}
'@

$generatedFiles += @{
    Path = Join-Path $rootPath "Authentication.Infrastructure\Persistence\Configurations\RoleConfiguration.cs"
    Content = $roleConfiguration
}

# =============================================================================
# REFRESH TOKEN CONFIGURATION
# =============================================================================

$refreshTokenConfiguration = @'
using Authentication.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Authentication.Infrastructure.Persistence.Configurations;

public sealed class RefreshTokenConfiguration
    : IEntityTypeConfiguration<RefreshToken>
{
    public void Configure(
        EntityTypeBuilder<RefreshToken> builder)
    {
        builder.ToTable("RefreshTokens");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Token)
            .HasMaxLength(500)
            .IsRequired();

        builder.HasIndex(x => x.Token)
            .IsUnique();

        builder.HasOne(x => x.User)
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .IsRequired()
            .OnDelete(DeleteBehavior.Restrict);
    }
}
'@

$generatedFiles += @{
    Path = Join-Path $rootPath "Authentication.Infrastructure\Persistence\Configurations\RefreshTokenConfiguration.cs"
    Content = $refreshTokenConfiguration
}

# =============================================================================
# AUTHENTICATION DBCONTEXT
# =============================================================================

$dbContext = @'
using Authentication.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Authentication.Infrastructure.Persistence;

public sealed class AuthenticationDbContext
    : DbContext
{
    public AuthenticationDbContext(
        DbContextOptions<AuthenticationDbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();

    public DbSet<Role> Roles => Set<Role>();

    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

    protected override void OnModelCreating(
        ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.ApplyConfigurationsFromAssembly(
            typeof(AuthenticationDbContext).Assembly);
    }
}
'@

$generatedFiles += @{
    Path = Join-Path $rootPath "Authentication.Infrastructure\Persistence\AuthenticationDbContext.cs"
    Content = $dbContext
}

# =============================================================================
# DATABASE EXTENSIONS
# =============================================================================

$databaseExtensions = @'
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Authentication.Infrastructure.Persistence.Extensions;

public static class DatabaseExtensions
{
    public static IServiceCollection AddDatabase(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var server =
            configuration["Database:Server"];

        var port =
            configuration["Database:Port"];

        var database =
            configuration["Database:Database"];

        if (string.IsNullOrWhiteSpace(server)
            || string.IsNullOrWhiteSpace(port)
            || string.IsNullOrWhiteSpace(database))
        {
            throw new InvalidOperationException(
                "As configurações 'Database:Server', 'Database:Port' e 'Database:Database' são obrigatórias.");
        }

        const string sqlPasswordSecretPath =
            "/run/secrets/sql_sa_password";

        if (!File.Exists(sqlPasswordSecretPath))
        {
            throw new InvalidOperationException(
                $"Docker Secret não encontrado em '{sqlPasswordSecretPath}'. Confirme que o serviço Authentication recebe o secret 'sql_sa_password'.");
        }

        var password =
            File.ReadAllText(sqlPasswordSecretPath).Trim();

        if (string.IsNullOrWhiteSpace(password))
        {
            throw new InvalidOperationException(
                "O Docker Secret 'sql_sa_password' está vazio.");
        }

        var connectionStringBuilder =
            new Microsoft.Data.SqlClient.SqlConnectionStringBuilder
            {
                DataSource = $"{server},{port}",
                InitialCatalog = database,
                UserID = "sa",
                Password = password,
                Encrypt = false,
                TrustServerCertificate = true,
                MultipleActiveResultSets = true
            };

        var connectionString = connectionStringBuilder.ConnectionString;

        services.AddDbContext<AuthenticationDbContext>(
            options =>
            {
                options.UseSqlServer(
                    connectionString);
            });

        return services;
    }
}
'@

$generatedFiles += @{
    Path = Join-Path $rootPath "Authentication.Infrastructure\Persistence\Extensions\DatabaseExtensions.cs"
    Content = $databaseExtensions
}

# =============================================================================
# DESIGN TIME FACTORY
# =============================================================================

$factory = @'
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Authentication.Infrastructure.Persistence.DesignTime;

public sealed class AuthenticationDbContextFactory
    : IDesignTimeDbContextFactory<AuthenticationDbContext>
{
    public AuthenticationDbContext CreateDbContext(
        string[] args)
    {
        var connectionStringBuilder =
            new Microsoft.Data.SqlClient.SqlConnectionStringBuilder
            {
                DataSource = "localhost,1433",
                InitialCatalog = "Db_Authentication",
                UserID = "sa",
                Password = "DesignTimeOnly",
                Encrypt = false,
                TrustServerCertificate = true
            };

        var builder =
            new DbContextOptionsBuilder<AuthenticationDbContext>();

        builder.UseSqlServer(connectionStringBuilder.ConnectionString);

        return new AuthenticationDbContext(
            builder.Options);
    }
}
'@

$generatedFiles += @{
    Path = Join-Path $rootPath "Authentication.Infrastructure\Persistence\DesignTime\AuthenticationDbContextFactory.cs"
    Content = $factory
}

# =============================================================================
# BUILD
# =============================================================================

foreach ($file in $generatedFiles) {
    if (-not (Test-Path -LiteralPath $file.Path)) {
        continue
    }

    $existingContent = (Get-Content -LiteralPath $file.Path -Raw).Replace("`r`n", "`n").TrimEnd()
    $expectedContent = $file.Content.Replace("`r`n", "`n").TrimEnd()
    if ($existingContent -cne $expectedContent) {
        throw "Arquivo ja existe com conteudo diferente e nao sera sobrescrito: $($file.Path)"
    }
}

foreach ($file in $generatedFiles) {
    if (Test-Path -LiteralPath $file.Path) {
        Write-Host "Arquivo existente e validado: $($file.Path)" -ForegroundColor Gray
        continue
    }

    Set-Content -LiteralPath $file.Path -Value $file.Content -Encoding utf8
    Write-Host "Arquivo criado: $($file.Path)" -ForegroundColor Green
}

Write-Host "Validando build da solution Authentication..." -ForegroundColor Yellow
Invoke-DotNet -Arguments @("build", $solutionPath)

$migrationsDirectory = Join-Path $rootPath "Authentication.Infrastructure\Persistence\Migrations"
$initialMigration = Get-ChildItem -LiteralPath $migrationsDirectory -Filter "*_InitialCreate.cs" -File -ErrorAction SilentlyContinue |
    Select-Object -First 1

if ($initialMigration) {
    Write-Host "Migration InitialCreate ja existe; nao sera sobrescrita." -ForegroundColor Gray
}
else {
    Write-Host "Criando a Migration InitialCreate..." -ForegroundColor Cyan
    Invoke-DotNet -Arguments @(
        "ef", "migrations", "add", "InitialCreate",
        "--project", $infrastructureProject,
        "--startup-project", $infrastructureProject,
        "--output-dir", "Persistence/Migrations",
        "--context", "AuthenticationDbContext"
    )
}

Write-Host "Fase 6 concluida: persistencia criada e build validado." -ForegroundColor Green