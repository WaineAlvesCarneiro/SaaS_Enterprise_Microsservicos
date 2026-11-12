# cria o Seed inicial da Authentication
# Role Admin + Usuario Admin

$ErrorActionPreference = "Stop"

Write-Host "Iniciando Seed da Authentication..." -ForegroundColor Cyan

$rootPath = Join-Path $PSScriptRoot "Servicos\Authentication"
$targetFrameworkFile = Join-Path $PSScriptRoot "Authentication.TargetFramework.txt"

if (-not (Test-Path -LiteralPath $targetFrameworkFile)) {
    throw "Arquivo Authentication.TargetFramework.txt nao encontrado: $targetFrameworkFile. Execute a Fase 3 primeiro."
}

$targetFramework = (Get-Content -LiteralPath $targetFrameworkFile -Raw).Trim()
if ($targetFramework -notmatch '^net\d+\.0$') {
    throw "TargetFramework invalido em ${targetFrameworkFile}: $targetFramework"
}

Write-Host "TargetFramework detectado: $targetFramework" -ForegroundColor Green

$programPath = Join-Path $rootPath "Authentication.API\Program.cs"

if (-not (Test-Path -LiteralPath $programPath)) {
    throw "Program.cs nao encontrado. Execute e valide a Fase anterior antes da Fase 8."
}

New-Item -ItemType Directory -Force -Path "$rootPath/Authentication.Infrastructure/Seed" | Out-Null

# SEED DATA
$seedData = @'
using Authentication.Domain.Entities;
using Authentication.Infrastructure.Persistence;
using Authentication.Infrastructure.Security;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Authentication.Infrastructure.Seed;

public static class SeedData
{
    public static async Task InitializeAsync(IServiceProvider services)
    {
        using var scope = services.CreateScope();
        var context = scope.ServiceProvider .GetRequiredService<AuthenticationDbContext>();
        await CreateAdminRoleAsync(context);
        await CreateAdminUserAsync(context);
    }

    private static async Task CreateAdminRoleAsync(AuthenticationDbContext context)
    {
        var roleExists = await context.Roles.AnyAsync(x => x.Name == "Admin");

        if (roleExists) return;

        context.Roles.Add(new Role
        {
            Id = Guid.NewGuid(),
            Name = "Admin"
        });

        await context.SaveChangesAsync();
    }

    private static async Task CreateAdminUserAsync(AuthenticationDbContext context)
    {
        var userExists = await context.Users.AnyAsync(x => x.Email == "admin@local.com");

        if (userExists) return;

        var adminRole = await context.Roles.FirstAsync(x => x.Name == "Admin");

        var passwordHasher = new PasswordHasher();

        context.Users.Add(new User
        {
            Id = Guid.NewGuid(),
            Name = "Administrador",
            Email = "admin@local.com",
            PasswordHash = passwordHasher.Hash("Admin@123"),
            RoleId = adminRole.Id
        });

        await context.SaveChangesAsync();
    }
}
'@

Set-Content "$rootPath/Authentication.Infrastructure/Seed/SeedData.cs" $seedData

$programContent = Get-Content -LiteralPath $programPath -Raw

if ($programContent -notmatch '(?m)^using Authentication\.Infrastructure\.Seed;') {
    $usingAnchor = "using Authentication.Infrastructure.Persistence.Extensions;"

    if (-not $programContent.Contains($usingAnchor)) {
        throw "O using de Persistence.Extensions nao foi encontrado no Program.cs."
    }

    $programContent = $programContent.Replace(
        $usingAnchor,
        "$usingAnchor`r`nusing Authentication.Infrastructure.Seed;")
}

if ($programContent -notmatch '(?m)^await app\.Services\.InitializeDatabaseAsync\(\);') {
    throw "A inicializacao do banco nao foi encontrada no Program.cs."
}

if ($programContent -notmatch '(?m)^await SeedData\.InitializeAsync\(app\.Services\);') {
    $databaseInitialization = "await app.Services.InitializeDatabaseAsync();"

    $programContent = $programContent.Replace(
        $databaseInitialization,
        "$databaseInitialization`r`nawait SeedData.InitializeAsync(app.Services);")
}

Set-Content -LiteralPath $programPath -Value $programContent -Encoding utf8
Write-Host "Seed integrado ao Program.cs: $programPath" -ForegroundColor Green

# BUILD
$solution = Get-ChildItem -Path $rootPath -Filter "Authentication.slnx*" | Select-Object -First 1

if (-not $solution)
{
    throw "Authentication.slnx nao encontrada."
}

Write-Host "Executando Build para $targetFramework..." -ForegroundColor Yellow

dotnet build $solution.FullName --framework $targetFramework
if ($LASTEXITCODE -ne 0) {
    throw "Build da solution Authentication falhou para $targetFramework."
}

Write-Host "Essa Fase foi concluida com sucesso." -ForegroundColor Green