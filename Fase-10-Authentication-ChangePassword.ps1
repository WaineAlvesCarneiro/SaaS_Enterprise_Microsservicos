# cria funcionalidade de troca de senha

$ErrorActionPreference = "Stop"

Write-Host "🚀 Iniciando Fase-10: Troca de Senha..." -ForegroundColor Cyan

$rootPath = "Services/Authentication"

# =============================================================================
# CHANGE PASSWORD REQUEST
# =============================================================================

$changePasswordRequest = @'
namespace Authentication.Application.DTOs;

public sealed class ChangePasswordRequest
{
    public string Email { get; set; }
        = string.Empty;

    public string CurrentPassword { get; set; }
        = string.Empty;

    public string NewPassword { get; set; }
        = string.Empty;
}
'@

Set-Content `
"$rootPath/Authentication.Application/DTOs/ChangePasswordRequest.cs" `
$changePasswordRequest

# =============================================================================
# COMMAND
# =============================================================================

$changePasswordCommand = @'
using MediatR;

namespace Authentication.Application.Features.Auth.Commands;

public sealed record ChangePasswordCommand(
    string Email,
    string CurrentPassword,
    string NewPassword)
    : IRequest<bool>;
'@

Set-Content `
"$rootPath/Authentication.Application/Features/Auth/Commands/ChangePasswordCommand.cs" `
$changePasswordCommand

# =============================================================================
# VALIDATOR
# =============================================================================

$validator = @'
using FluentValidation;

namespace Authentication.Application.Features.Auth.Commands;

public sealed class ChangePasswordCommandValidator
    : AbstractValidator<ChangePasswordCommand>
{
    public ChangePasswordCommandValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress();

        RuleFor(x => x.CurrentPassword)
            .NotEmpty();

        RuleFor(x => x.NewPassword)
            .NotEmpty()
            .MinimumLength(8);

        RuleFor(x => x.NewPassword)
            .Matches("[A-Z]")
            .WithMessage("Deve conter letra maiúscula.");

        RuleFor(x => x.NewPassword)
            .Matches("[a-z]")
            .WithMessage("Deve conter letra minúscula.");

        RuleFor(x => x.NewPassword)
            .Matches("[0-9]")
            .WithMessage("Deve conter número.");
    }
}
'@

Set-Content `
"$rootPath/Authentication.Application/Features/Auth/Commands/ChangePasswordCommandValidator.cs" `
$validator

# =============================================================================
# HANDLER
# =============================================================================

$handler = @'
using Authentication.Infrastructure.Persistence;
using Authentication.Infrastructure.Security;

using MediatR;

using Microsoft.EntityFrameworkCore;

namespace Authentication.Application.Features.Auth.Commands;

public sealed class ChangePasswordCommandHandler
    : IRequestHandler<ChangePasswordCommand, bool>
{
    private readonly AuthenticationDbContext _context;

    public ChangePasswordCommandHandler(
        AuthenticationDbContext context)
    {
        _context = context;
    }

    public async Task<bool> Handle(
        ChangePasswordCommand request,
        CancellationToken cancellationToken)
    {
        var user =
            await _context.Users
                .FirstOrDefaultAsync(
                    x => x.Email == request.Email,
                    cancellationToken);

        if (user is null)
        {
            throw new UnauthorizedAccessException(
                "Usuário não encontrado.");
        }

        var passwordValid =
            PasswordHasher.Verify(
                request.CurrentPassword,
                user.PasswordHash);

        if (!passwordValid)
        {
            throw new UnauthorizedAccessException(
                "Senha atual inválida.");
        }

        user.PasswordHash =
            PasswordHasher.Hash(
                request.NewPassword);

        user.FirstAccess = false;

        user.UpdatedAt =
            DateTime.UtcNow;

        await _context.SaveChangesAsync(
            cancellationToken);

        return true;
    }
}
'@

Set-Content `
"$rootPath/Authentication.Application/Features/Auth/Commands/ChangePasswordCommandHandler.cs" `
$handler

# =============================================================================
# AUTH CONTROLLER (ADICIONAR MÉTODO)
# =============================================================================

Write-Host ""
Write-Host "⚠️ Adicionar manualmente ao AuthController:" -ForegroundColor Yellow

Write-Host @"

[HttpPost("change-password")]
public async Task<IActionResult> ChangePassword(
    [FromBody] ChangePasswordRequest request)
{
    var result =
        await _mediator.Send(
            new ChangePasswordCommand(
                request.Email,
                request.CurrentPassword,
                request.NewPassword));

    return Ok(new
    {
        Success = result
    });
}

"@

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
Write-Host "✅ ChangePasswordRequest criada." -ForegroundColor Green
Write-Host "✅ ChangePasswordCommand criado." -ForegroundColor Green
Write-Host "✅ ChangePasswordValidator criado." -ForegroundColor Green
Write-Host "✅ ChangePasswordHandler criado." -ForegroundColor Green
Write-Host "✅ Troca obrigatória de senha preparada." -ForegroundColor Green
Write-Host "✅ Build executado com sucesso." -ForegroundColor Green
Write-Host ""