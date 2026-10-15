# cria o Seed inicial da Authentication
# Role Admin + Usuario Admin

$ErrorActionPreference = "Stop"

Write-Host "🚀 Iniciando Fase-7: Seed da Authentication..." -ForegroundColor Cyan

$rootPath = "Servicos/Authentication"

# =============================================================================
# SEED DATA
# =============================================================================

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

# =============================================================================
# PROGRAM.CS
# =============================================================================

$program = @'
using System.Text;

using Authentication.Application.Behaviors;
using Authentication.Infrastructure.Persistence;
using Authentication.Infrastructure.Persistence.Extensions;
using Authentication.Infrastructure.Security;
using Authentication.Infrastructure.Seed;

using FluentValidation;

using MediatR;

using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

#region Controllers

builder.Services.AddControllers();

#endregion

#region OpenApi

builder.Services.AddEndpointsApiExplorer();

builder.Services.AddOpenApi();

builder.Services.AddSwaggerGen();

#endregion

#region Database

builder.Services.AddDatabase(
    builder.Configuration);

#endregion

#region MediatR

builder.Services.AddMediatR(cfg =>
{
    cfg.RegisterServicesFromAssembly(
        typeof(Authentication.Application.Interfaces.ITokenService)
            .Assembly);
});

builder.Services.AddValidatorsFromAssembly(
    typeof(Authentication.Application.Interfaces.ITokenService)
        .Assembly);

builder.Services.AddTransient(
    typeof(IPipelineBehavior<,>),
    typeof(ValidationBehavior<,>));

#endregion

#region JWT

var jwtKey =
    SecretReader.Read(
        "jwt_key",
        "JWT_KEY");

var issuer =
    builder.Configuration["Jwt:Issuer"];

var audience =
    builder.Configuration["Jwt:Audience"];

builder.Services
    .AddAuthentication(
        JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters =
            new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateIssuerSigningKey = true,
                ValidateLifetime = true,

                ValidIssuer = issuer,

                ValidAudience = audience,

                IssuerSigningKey =
                    new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(jwtKey))
            };
    });

builder.Services.AddAuthorization();

#endregion

#region HealthChecks

builder.Services.AddHealthChecks()
    .AddDbContextCheck<AuthenticationDbContext>();

#endregion

var app = builder.Build();

#region DatabaseMigration

using (var scope = app.Services.CreateScope())
{
    var context =
        scope.ServiceProvider
            .GetRequiredService<AuthenticationDbContext>();

    context.Database.Migrate();

    await SeedData.InitializeAsync(
        scope.ServiceProvider);
}

#endregion

#region Pipeline

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();

    app.UseSwagger();

    app.UseSwaggerUI();
}

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.MapHealthChecks("/health");

app.Run();

#endregion
'@

Set-Content `
"$rootPath/Authentication.API/Program.cs" `
$program

# =============================================================================
# BUILD
# =============================================================================

$solution = Get-ChildItem `
    -Path $rootPath `
    -Filter "Authentication.slnx*" |
    Select-Object -First 1

Write-Host ""
Write-Host "🔨 Executando Build..." -ForegroundColor Yellow

dotnet build $solution.FullName

Write-Host ""
Write-Host "✅ SeedData criado." -ForegroundColor Green
Write-Host "✅ Role Admin configurada." -ForegroundColor Green
Write-Host "✅ Usuário Admin configurado." -ForegroundColor Green
Write-Host "✅ FirstAccess configurado." -ForegroundColor Green
Write-Host "✅ Program.cs atualizado." -ForegroundColor Green
Write-Host "✅ Migration automática configurada." -ForegroundColor Green
Write-Host "✅ Seed automático configurado." -ForegroundColor Green
Write-Host "✅ Build executado com sucesso." -ForegroundColor Green
Write-Host ""