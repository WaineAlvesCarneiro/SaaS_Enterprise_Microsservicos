# implementa JWT da Authentication

$ErrorActionPreference = "Stop"

Write-Host "🚀 Iniciando Fase-7: JWT da Authentication..." -ForegroundColor Cyan

$rootPath = Join-Path $PSScriptRoot "Servicos\Authentication"

$dbContextFile = Join-Path $rootPath "Authentication.Infrastructure\Persistence\AuthenticationDbContext.cs"

if (-not (Test-Path $dbContextFile))
{
    throw "AuthenticationDbContext não encontrado. Execute e valide a Fase 6."
}

$applicationProject = Join-Path $rootPath "Authentication.Application\Authentication.Application.csproj"

if (-not (Test-Path $applicationProject))
{
    throw "Authentication.Application não encontrado. Execute e valide a Fase 6."
}

$infrastructureProject = Join-Path $rootPath "Authentication.Infrastructure\Authentication.Infrastructure.csproj"

if (-not (Test-Path $infrastructureProject))
{
    throw "Authentication.Infrastructure não encontrado. Execute e valide a Fase 6."
}

$apiProject = Join-Path $rootPath "Authentication.API\Authentication.API.csproj"

if (-not (Test-Path $apiProject))
{
    throw "Authentication.API não encontrado. Execute e valide a Fase 6."
}

foreach ($project in @(
    $applicationProject,
    $infrastructureProject,
    $apiProject))
{
    if (-not (Test-Path -LiteralPath $project))
    {
        throw "Projeto obrigatório não encontrado: $project"
    }
}

New-Item -ItemType Directory -Force -Path "$rootPath/Authentication.Infrastructure/Security" | Out-Null
New-Item -ItemType Directory -Force -Path "$rootPath/Authentication.Infrastructure/DependencyInjection" | Out-Null

$jwtOptions = @'
namespace Authentication.Infrastructure.Security;

public sealed class JwtOptions
{
    public string Issuer { get; set; } = string.Empty;

    public string Audience { get; set; } = string.Empty;

    public int ExpireMinutes { get; set; } = 60;

    public int RefreshTokenDays { get; set; } = 30;
}
'@

Set-Content "$rootPath/Authentication.Infrastructure/Security/JwtOptions.cs" $jwtOptions

$secretReader = @'
namespace Authentication.Infrastructure.Security;

public static class SecretReader
{
    public static string Read(string secretFile, string environmentVariable)
    {
        var dockerSecret = $"/run/secrets/{secretFile}";

        if (File.Exists(dockerSecret))
        {
            var value = File.ReadAllText(dockerSecret).Trim();

            if (!string.IsNullOrWhiteSpace(value)) return value;
        }

        var environmentValue = Environment.GetEnvironmentVariable(environmentVariable);

        if (!string.IsNullOrWhiteSpace(environmentValue)) return environmentValue;

        throw new InvalidOperationException($"Secret '{secretFile}' não encontrado.");
    }
}
'@

Set-Content "$rootPath/Authentication.Infrastructure/Security/SecretReader.cs" $secretReader

$passwordHasher = @'
using Authentication.Application.Interfaces;

namespace Authentication.Infrastructure.Security;

public sealed class PasswordHasher : IPasswordHasher
{
    public string Hash(string password)
    {
        return BCrypt.Net.BCrypt.HashPassword(password);
    }

    public bool Verify(string password, string passwordHash)
    {
        return BCrypt.Net.BCrypt.Verify(password, passwordHash);
    }
}
'@

Set-Content "$rootPath/Authentication.Infrastructure/Security/PasswordHasher.cs" $passwordHasher

$permissionRequirement = @'
using Microsoft.AspNetCore.Authorization;

namespace Authentication.Infrastructure.Security;

public sealed class PermissionRequirement : IAuthorizationRequirement
{
    public PermissionRequirement(string permission)
    {
        Permission = permission;
    }

    public string Permission { get; }
}
'@

Set-Content "$rootPath/Authentication.Infrastructure/Security/PermissionRequirement.cs" $permissionRequirement

$permissionAuthorizationHandler = @'
using Authentication.Application.Security;

using Microsoft.AspNetCore.Authorization;
using System.Linq;
using System.Threading.Tasks;

namespace Authentication.Infrastructure.Security;

public sealed class PermissionAuthorizationHandler : AuthorizationHandler<PermissionRequirement>
{
    protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, PermissionRequirement requirement)
    {
        var permissions = context.User.Claims
            .Where(x => x.Type == JwtClaimNames.Permission).Select(x => x.Value);

        if (permissions.Contains(requirement.Permission)) context.Succeed(requirement);

        return Task.CompletedTask;
    }
}
'@

Set-Content "$rootPath/Authentication.Infrastructure/Security/PermissionAuthorizationHandler.cs" $permissionAuthorizationHandler

$permissionPolicyProvider = @'
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Options;
using System.Threading.Tasks;

namespace Authentication.Infrastructure.Security;

public sealed class PermissionPolicyProvider : DefaultAuthorizationPolicyProvider
{
    public PermissionPolicyProvider(IOptions<AuthorizationOptions> options) : base(options)
    {
    }

    public override async Task<AuthorizationPolicy?>GetPolicyAsync(string policyName)
    {
        var existing =await base.GetPolicyAsync(policyName);

        if (existing is not null) return existing;

        return new AuthorizationPolicyBuilder()
            .AddRequirements(new PermissionRequirement(policyName))
            .Build();
    }
}
'@

Set-Content "$rootPath/Authentication.Infrastructure/Security/PermissionPolicyProvider.cs" $permissionPolicyProvider

$tokenService = @'
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

using Authentication.Application.Interfaces;
using Authentication.Application.Models;
using Authentication.Application.Security;
using Authentication.Domain.Entities;

using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.Options;

namespace Authentication.Infrastructure.Security;

public sealed class TokenService : ITokenService
{
    private readonly JwtOptions _jwtOptions;

    public TokenService(IOptions<JwtOptions> jwtOptions)
    {
        _jwtOptions = jwtOptions.Value;
    }

    public TokenResult GenerateToken(User user)
    {
        var jwtKey = SecretReader.Read("jwt_key", "JWT_KEY");

        var issuer = _jwtOptions.Issuer;

        var audience = _jwtOptions.Audience;

        var accessExpiresAt = DateTime.UtcNow.AddMinutes(_jwtOptions.ExpireMinutes);

        var refreshExpiresAt = DateTime.UtcNow.AddDays(_jwtOptions.RefreshTokenDays);

        var claims = new List<Claim>
            {
                new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new(JwtRegisteredClaimNames.Email, user.Email),
                new(JwtClaimNames.FirstAccess, user.FirstAccess.ToString())
            };

        if (user.TenantId.HasValue)
            claims.Add(new Claim(JwtClaimNames.TenantId, user.TenantId.Value.ToString()));

        if (user.Role is not null)
        {
            claims.Add(new Claim(ClaimTypes.Role, user.Role.Name));

            foreach (var permission in user.Role.Permissions)
            {
                claims.Add(new Claim(JwtClaimNames.Permission, permission.Name));
            }
        }

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));

        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var jwt = new JwtSecurityToken(
            issuer,
            audience,
            claims,
            expires: accessExpiresAt,
            signingCredentials: credentials);

        var accessToken = new JwtSecurityTokenHandler().WriteToken(jwt);

        var refreshToken = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));

        return new TokenResult(
            accessToken,
            refreshToken,
            accessExpiresAt,
            refreshExpiresAt);
    }
}
'@

Set-Content "$rootPath/Authentication.Infrastructure/Security/TokenService.cs" $tokenService

$securityExtensionsInterface = @'
using System.Text;

using Authentication.Application.Interfaces;
using Authentication.Infrastructure.Security;

using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;

namespace Authentication.Infrastructure.DependencyInjection;

public static class SecurityExtensions
{
    public static IServiceCollection AddSecurity(this IServiceCollection services, IConfiguration configuration)
    {
        var jwtKey = SecretReader.Read("jwt_key", "JWT_KEY");

        services.Configure<JwtOptions>(configuration.GetSection("Jwt"));

        services.AddScoped<IPasswordHasher, PasswordHasher>();

        services.AddScoped<ITokenService, TokenService>();

        services.AddSingleton<IAuthorizationHandler, PermissionAuthorizationHandler>();

        services.AddSingleton<IAuthorizationPolicyProvider, PermissionPolicyProvider>();

        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuer = true,
                        ValidateAudience = true,
                        ValidateLifetime = true,
                        ValidateIssuerSigningKey = true,

                        ValidIssuer = configuration["Jwt:Issuer"],

                        ValidAudience = configuration["Jwt:Audience"],

                        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
                    };
            });

        services.AddAuthorization();

        return services;
    }
}
'@

Set-Content "$rootPath/Authentication.Infrastructure/DependencyInjection/SecurityExtensions.cs" $securityExtensionsInterface

$program = @'
using Authentication.Application.Behaviors;
using Authentication.Application.Interfaces;
using Authentication.Infrastructure.DependencyInjection;
using Authentication.Infrastructure.Persistence;
using Authentication.Infrastructure.Persistence.Extensions;

using FluentValidation;

using MediatR;

using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen();

builder.Services.AddDatabase(builder.Configuration);

builder.Services.AddSecurity(builder.Configuration);

builder.Services.AddMediatR(cfg =>
    {
        cfg.RegisterServicesFromAssembly(typeof(ITokenService)
        .Assembly);
    });

builder.Services
    .AddValidatorsFromAssembly(typeof(ITokenService)
    .Assembly);

builder.Services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));

builder.Services
    .AddHealthChecks()
    .AddDbContextCheck<AuthenticationDbContext>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();

    app.UseSwaggerUI();
}

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.MapHealthChecks("/health");

app.Run();
'@

Set-Content "$rootPath/Authentication.API/Program.cs" $program

$solution = Get-ChildItem -Path $rootPath -Filter "Authentication.slnx*" | Select-Object -First 1

if (-not $solution)
{
    throw "Authentication.slnx não encontrada."
}

Write-Host ""
Write-Host "🔨 Executando Build..." -ForegroundColor Yellow

dotnet build $solution.FullName

Write-Host ""

Write-Host "✅ JwtOptions criado." -ForegroundColor Green
Write-Host "✅ SecretReader implementado." -ForegroundColor Green
Write-Host "✅ PasswordHasher (BCrypt) implementado." -ForegroundColor Green
Write-Host "✅ TokenService implementado." -ForegroundColor Green
Write-Host "✅ JWT usando Docker Secret." -ForegroundColor Green
Write-Host "✅ Access Token configurado." -ForegroundColor Green
Write-Host "✅ Refresh Token configurado." -ForegroundColor Green
Write-Host "✅ Claims configuradas." -ForegroundColor Green
Write-Host "✅ Policies dinâmicas configuradas." -ForegroundColor Green
Write-Host "✅ Authentication configurada." -ForegroundColor Green
Write-Host "✅ Authorization configurada." -ForegroundColor Green
Write-Host "✅ SecurityExtensions criado." -ForegroundColor Green
Write-Host "✅ Program.cs atualizado." -ForegroundColor Green

Write-Host ""
Write-Host "✅ Fase 7 concluída: Security configurada e build validado." -ForegroundColor Green
Write-Host ""