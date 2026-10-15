# cria autenticação de login

$ErrorActionPreference = "Stop"

Write-Host "🚀 Iniciando Fase-9: Login da Authentication..." -ForegroundColor Cyan

$rootPath = "Servicos/Authentication"

# =============================================================================
# LOGIN REQUEST
# =============================================================================

$loginRequest = @'
namespace Authentication.Application.DTOs;

public sealed class LoginRequest
{
    public string Email { get; set; }
        = string.Empty;

    public string Password { get; set; }
        = string.Empty;
}
'@

Set-Content `
"$rootPath/Authentication.Application/DTOs/LoginRequest.cs" `
$loginRequest

# =============================================================================
# LOGIN RESPONSE
# =============================================================================

$loginResponse = @'
namespace Authentication.Application.DTOs;

public sealed class LoginResponse
{
    public string Token { get; set; }
        = string.Empty;

    public bool FirstAccess { get; set; }

    public string Role { get; set; }
        = string.Empty;
}
'@

Set-Content `
"$rootPath/Authentication.Application/DTOs/LoginResponse.cs" `
$loginResponse

# =============================================================================
# LOGIN COMMAND
# =============================================================================

$loginCommand = @'
using Authentication.Application.DTOs;
using MediatR;

namespace Authentication.Application.Features.Auth.Commands;

public sealed record LoginCommand(
    string Email,
    string Password)
    : IRequest<LoginResponse>;
'@

Set-Content `
"$rootPath/Authentication.Application/Features/Auth/Commands/LoginCommand.cs" `
$loginCommand

# =============================================================================
# LOGIN VALIDATOR
# =============================================================================

$loginValidator = @'
using FluentValidation;

namespace Authentication.Application.Features.Auth.Commands;

public sealed class LoginCommandValidator
    : AbstractValidator<LoginCommand>
{
    public LoginCommandValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress();

        RuleFor(x => x.Password)
            .NotEmpty()
            .MinimumLength(3);
    }
}
'@

Set-Content `
"$rootPath/Authentication.Application/Features/Auth/Commands/LoginCommandValidator.cs" `
$loginValidator

# =============================================================================
# LOGIN HANDLER
# =============================================================================

$loginHandler = @'
using Authentication.Application.DTOs;
using Authentication.Application.Interfaces;
using Authentication.Infrastructure.Persistence;
using Authentication.Infrastructure.Security;

using MediatR;

using Microsoft.EntityFrameworkCore;

namespace Authentication.Application.Features.Auth.Commands;

public sealed class LoginCommandHandler
    : IRequestHandler<LoginCommand, LoginResponse>
{
    private readonly AuthenticationDbContext _context;

    private readonly ITokenService _tokenService;

    public LoginCommandHandler(
        AuthenticationDbContext context,
        ITokenService tokenService)
    {
        _context = context;
        _tokenService = tokenService;
    }

    public async Task<LoginResponse> Handle(
        LoginCommand request,
        CancellationToken cancellationToken)
    {
        var user =
            await _context.Users
                .Include(x => x.Role)
                .FirstOrDefaultAsync(
                    x => x.Email == request.Email,
                    cancellationToken);

        if (user is null)
        {
            throw new UnauthorizedAccessException(
                "Usuário ou senha inválidos.");
        }

        var passwordValid =
            PasswordHasher.Verify(
                request.Password,
                user.PasswordHash);

        if (!passwordValid)
        {
            throw new UnauthorizedAccessException(
                "Usuário ou senha inválidos.");
        }

        user.LastLoginAt =
            DateTime.UtcNow;

        await _context.SaveChangesAsync(
            cancellationToken);

        var token =
            _tokenService.GenerateToken(
                user.Id,
                user.Email,
                user.Role?.Name ?? "User",
                user.FirstAccess);

        return new LoginResponse
        {
            Token = token,

            FirstAccess = user.FirstAccess,

            Role = user.Role?.Name ?? "User"
        };
    }
}
'@

Set-Content `
"$rootPath/Authentication.Application/Features/Auth/Commands/LoginCommandHandler.cs" `
$loginHandler

# =============================================================================
# AUTH CONTROLLER
# =============================================================================

$authController = @'
using Authentication.Application.DTOs;
using Authentication.Application.Features.Auth.Commands;

using MediatR;

using Microsoft.AspNetCore.Mvc;

namespace Authentication.API.Controllers;

[ApiController]
[Route("api/auth")]
public sealed class AuthController : ControllerBase
{
    private readonly IMediator _mediator;

    public AuthController(
        IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpPost("login")]
    [ProducesResponseType(typeof(LoginResponse), 200)]
    public async Task<IActionResult> Login(
        [FromBody] LoginRequest request)
    {
        var result =
            await _mediator.Send(
                new LoginCommand(
                    request.Email,
                    request.Password));

        return Ok(result);
    }
}
'@

Set-Content `
"$rootPath/Authentication.API/Controllers/AuthController.cs" `
$authController

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
Write-Host "✅ LoginRequest criada." -ForegroundColor Green
Write-Host "✅ LoginResponse criada." -ForegroundColor Green
Write-Host "✅ LoginCommand criado." -ForegroundColor Green
Write-Host "✅ LoginCommandValidator criado." -ForegroundColor Green
Write-Host "✅ LoginCommandHandler criado." -ForegroundColor Green
Write-Host "✅ AuthController criado." -ForegroundColor Green
Write-Host "✅ Endpoint POST /api/auth/login criado." -ForegroundColor Green
Write-Host "✅ Build executado com sucesso." -ForegroundColor Green
Write-Host ""