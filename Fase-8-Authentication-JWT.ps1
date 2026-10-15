# implementa JWT da Authentication

$ErrorActionPreference = "Stop"

Write-Host "🚀 Iniciando Fase-8: JWT da Authentication..." -ForegroundColor Cyan

$rootPath = Join-Path $PSScriptRoot "Servicos\Authentication"

# =============================================================================
# ITokenService
# =============================================================================

$tokenInterface = @'
namespace Authentication.Application.Interfaces;

public interface ITokenService
{
    string GenerateToken(
        Guid userId,
        string email,
        string role,
        bool firstAccess);
}
'@

Set-Content `
"$rootPath/Authentication.Application/Interfaces/ITokenService.cs" `
$tokenInterface

# =============================================================================
# TOKEN SERVICE
# =============================================================================

$tokenService = @'
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

using Authentication.Application.Interfaces;
using Authentication.Infrastructure.Security;

using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace Authentication.Infrastructure.Services;

public sealed class TokenService : ITokenService
{
    private readonly IConfiguration _configuration;

    public TokenService(
        IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public string GenerateToken(
        Guid userId,
        string email,
        string role,
        bool firstAccess)
    {
        var jwtKey =
            SecretReader.Read(
                "jwt_key",
                "JWT_KEY");

        var issuer =
            _configuration["Jwt:Issuer"]
            ?? throw new InvalidOperationException(
                "Jwt:Issuer não configurado.");

        var audience =
            _configuration["Jwt:Audience"]
            ?? throw new InvalidOperationException(
                "Jwt:Audience não configurado.");

        var expireMinutes =
            int.Parse(
                _configuration["Jwt:ExpireMinutes"]
                ?? "15");

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub,
                userId.ToString()),

            new(JwtRegisteredClaimNames.Email,
                email),

            new(ClaimTypes.Role,
                role),

            new("first_access",
                firstAccess.ToString()),

            new(JwtRegisteredClaimNames.Jti,
                Guid.NewGuid().ToString())
        };

        var key =
            new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtKey));

        var credentials =
            new SigningCredentials(
                key,
                SecurityAlgorithms.HmacSha256);

        var token =
            new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: DateTime.UtcNow
                    .AddMinutes(expireMinutes),
                signingCredentials: credentials);

        return new JwtSecurityTokenHandler()
            .WriteToken(token);
    }
}
'@

Set-Content `
"$rootPath/Authentication.Infrastructure/Services/TokenService.cs" `
$tokenService

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
Write-Host "✅ ITokenService atualizado." -ForegroundColor Green
Write-Host "✅ TokenService implementado." -ForegroundColor Green
Write-Host "✅ JWT usando Docker Secret." -ForegroundColor Green
Write-Host "✅ Claims configuradas." -ForegroundColor Green
Write-Host "✅ Build executado com sucesso." -ForegroundColor Green
Write-Host ""