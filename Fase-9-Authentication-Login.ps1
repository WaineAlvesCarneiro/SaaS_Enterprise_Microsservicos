# cria autenticação de login

$ErrorActionPreference = "Stop"

Write-Host "Iniciando Login da Authentication..." -ForegroundColor Cyan

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

New-Item -ItemType Directory -Force -Path "$rootPath/Authentication.Application/DTOs" | Out-Null
New-Item -ItemType Directory -Force -Path "$rootPath/Authentication.Application/Features/Auth/Commands" | Out-Null
New-Item -ItemType Directory -Force -Path "$rootPath/Authentication.API/Controllers" | Out-Null

# LOGIN REQUEST
$loginRequest = @'
namespace Authentication.Application.DTOs;

public sealed class LoginRequest
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}
'@

Set-Content "$rootPath/Authentication.Application/DTOs/LoginRequest.cs" $loginRequest

# LOGIN RESPONSE
$loginResponse = @'
namespace Authentication.Application.DTOs;

public sealed class LoginResponse
{
    public string Token { get; set; } = string.Empty;
    public bool FirstAccess { get; set; }
    public string Role { get; set; } = string.Empty;
}
'@

Set-Content "$rootPath/Authentication.Application/DTOs/LoginResponse.cs" $loginResponse

# LOGIN COMMAND
$loginCommand = @'
using Authentication.Application.DTOs;
using MediatR;

namespace Authentication.Application.Features.Auth.Commands;

public sealed record LoginCommand(string Email, string Password) : IRequest<LoginResponse>;
'@

Set-Content "$rootPath/Authentication.Application/Features/Auth/Commands/LoginCommand.cs" $loginCommand

# LOGIN VALIDATOR
$loginValidator = @'
using FluentValidation;

namespace Authentication.Application.Features.Auth.Commands;

public sealed class LoginCommandValidator : AbstractValidator<LoginCommand>
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

Set-Content "$rootPath/Authentication.Application/Features/Auth/Commands/LoginCommandValidator.cs" $loginValidator

# IUser Repository
$iUserRepository = @'
using Authentication.Domain.Entities;

namespace Authentication.Application.Interfaces;

public interface IUserRepository
{
    Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken);
    Task SaveChangesAsync(CancellationToken cancellationToken);
}
'@

Set-Content "$rootPath/Authentication.Application/Interfaces/IUserRepository.cs" $iUserRepository

# User Repository
$userRepository = @'
using Authentication.Application.Interfaces;
using Authentication.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Authentication.Infrastructure.Persistence;

public sealed class UserRepository(AuthenticationDbContext context) : IUserRepository
{
    public Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken)
    {
        return context.Users
            .Include(user => user.Role)
            .ThenInclude(role => role!.Permissions)
            .SingleOrDefaultAsync(user => user.Email == email, cancellationToken);
    }

    public Task SaveChangesAsync(CancellationToken cancellationToken)
    {
        return context.SaveChangesAsync(cancellationToken);
    }
}
'@

Set-Content "$rootPath/Authentication.Infrastructure/Persistence/UserRepository.cs" $userRepository

# LOGIN HANDLER
$loginHandler = @'
using Authentication.Application.DTOs;
using Authentication.Application.Interfaces;
using MediatR;

namespace Authentication.Application.Features.Auth.Commands;

public sealed class LoginCommandHandler(IUserRepository userRepository, IPasswordHasher passwordHasher, ITokenService tokenService)
    : IRequestHandler<LoginCommand, LoginResponse>
{
    private readonly IUserRepository _userRepository = userRepository;
    private readonly IPasswordHasher _passwordHasher = passwordHasher;
    private readonly ITokenService _tokenService = tokenService;

    public async Task<LoginResponse> Handle(LoginCommand request, CancellationToken cancellationToken)
    {
        var email = request.Email.Trim();
        var user = await _userRepository.GetByEmailAsync(email, cancellationToken);

        if (user is null || !user.Active || !_passwordHasher.Verify(request.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Usuário ou senha inválidos.");

        user.RegisterLogin();
        await _userRepository.SaveChangesAsync(cancellationToken);

        var token = _tokenService.GenerateToken(user);

        return new LoginResponse
        {
            Token = token.AccessToken,
            FirstAccess = user.FirstAccess,
            Role = user.Role?.Name ?? "User"
        };
    }
}
'@

Set-Content "$rootPath/Authentication.Application/Features/Auth/Commands/LoginCommandHandler.cs" $loginHandler

# AUTH CONTROLLER
$authController = @'
using Authentication.Application.DTOs;
using Authentication.Application.Features.Auth.Commands;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace Authentication.API.Controllers;

[ApiController]
[Route("api/auth")]
public sealed class AuthController(IMediator mediator) : ControllerBase
{
    private readonly IMediator _mediator = mediator;

    [HttpPost("login")]
    [ProducesResponseType(typeof(LoginResponse), 200)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var result = await _mediator.Send(new LoginCommand(request.Email, request.Password));
        return Ok(result);
    }
}
'@

Set-Content "$rootPath/Authentication.API/Controllers/AuthController.cs" $authController

# BUILD
$solution = Get-ChildItem -Path $rootPath -Filter "Authentication.slnx*" | Select-Object -First 1

if (-not $solution) {
    throw "Authentication.slnx nao encontrada."
}

Write-Host "Executando Build para $targetFramework sem paralelismo..." -ForegroundColor Yellow

dotnet build $solution.FullName --framework $targetFramework -m:1
if ($LASTEXITCODE -ne 0) {
    throw "Build da solution Authentication falhou para $targetFramework."
}

Write-Host "Essa Fase foi concluida com sucesso." -ForegroundColor Green