# cria o Seed inicial da Authentication
# Role Admin + Usuario Admin

$ErrorActionPreference = "Stop"

Write-Host "🚀 Iniciando Fase-8: Seed da Authentication..." -ForegroundColor Cyan

$rootPath = "Servicos/Authentication"

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
    public static async Task InitializeAsync(
        IServiceProvider services)
    {
        using var scope =
            services.CreateScope();

        var context =
            scope.ServiceProvider
                .GetRequiredService<AuthenticationDbContext>();

        await CreateAdminRoleAsync(context);

        await CreateAdminUserAsync(context);
    }

    private static async Task CreateAdminRoleAsync(
        AuthenticationDbContext context)
    {
        var roleExists =
            await context.Roles
                .AnyAsync(x =>
                    x.Name == "Admin");

        if (roleExists)
        {
            return;
        }

        context.Roles.Add(new Role
        {
            Id = Guid.NewGuid(),
            Name = "Admin"
        });

        await context.SaveChangesAsync();
    }

    private static async Task CreateAdminUserAsync(
        AuthenticationDbContext context)
    {
        var userExists =
            await context.Users
                .AnyAsync(x =>
                    x.Email == "admin@local.com");

        if (userExists)
        {
            return;
        }

        var adminRole =
            await context.Roles
                .FirstAsync(x =>
                    x.Name == "Admin");

        context.Users.Add(new User
        {
            Id = Guid.NewGuid(),

            Name = "Administrador",

            Email = "admin@local.com",

            PasswordHash =
                PasswordHasher.Hash(
                    "Admin@123"),

            Active = true,

            FirstAccess = true,

            RoleId = adminRole.Id,

            CreatedAt = DateTime.UtcNow
        });

        await context.SaveChangesAsync();
    }
}
'@

Set-Content `
"$rootPath/Authentication.Infrastructure/Seed/SeedData.cs" `
$seedData

# BUILD

$solution = Get-ChildItem `
    -Path $rootPath `
    -Filter "Authentication.slnx*" |
    Select-Object -First 1

Write-Host ""
Write-Host "🔨 Executando Build..." -ForegroundColor Yellow

dotnet build $solution.FullName

Write-Host ""
Write-Host "✅ SeedData criado." -ForegroundColor Green
Write-Host "✅ Seed automático configurado." -ForegroundColor Green
Write-Host "✅ Build executado com sucesso." -ForegroundColor Green
Write-Host ""