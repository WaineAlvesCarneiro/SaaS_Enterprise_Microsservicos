# cria funcionalidade de troca de senha

$ErrorActionPreference = "Stop"

Write-Host "Iniciando Fase Troca de Senha..." -ForegroundColor Cyan

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

# CHANGE PASSWORD REQUEST
$changePasswordRequest = @'
namespace Authentication.Application.DTOs;

public sealed class ChangePasswordRequest
{
    public string Email { get; set; } = string.Empty;
    public string CurrentPassword { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
}
'@

Set-Content "$rootPath/Authentication.Application/DTOs/ChangePasswordRequest.cs" $changePasswordRequest

# COMMAND
$changePasswordCommand = @'
using MediatR;

namespace Authentication.Application.Features.Auth.Commands;

public sealed record ChangePasswordCommand(string Email, string CurrentPassword, string NewPassword) : IRequest<bool>;
'@

Set-Content "$rootPath/Authentication.Application/Features/Auth/Commands/ChangePasswordCommand.cs" $changePasswordCommand

# VALIDATOR
$validator = @'
using FluentValidation;

namespace Authentication.Application.Features.Auth.Commands;

public sealed class ChangePasswordCommandValidator : AbstractValidator<ChangePasswordCommand>
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

Set-Content "$rootPath/Authentication.Application/Features/Auth/Commands/ChangePasswordCommandValidator.cs" $validator

# HANDLER
$handler = @'
using Authentication.Application.Interfaces;
using MediatR;

namespace Authentication.Application.Features.Auth.Commands;

public sealed class ChangePasswordCommandHandler : IRequestHandler<ChangePasswordCommand, bool>
{
    private readonly IUserRepository _users;
    private readonly IPasswordHasher _passwordHasher;

    public ChangePasswordCommandHandler(IUserRepository users, IPasswordHasher passwordHasher)
    {
        _users = users;
        _passwordHasher = passwordHasher;
    }

    public async Task<bool> Handle(ChangePasswordCommand request, CancellationToken cancellationToken)
    {
        var user = await _users.GetByEmailAsync(request.Email, cancellationToken);

        if (user is null)
            throw new UnauthorizedAccessException("Usuário não encontrado.");

        if (!_passwordHasher.Verify(request.CurrentPassword, user.PasswordHash))
            throw new UnauthorizedAccessException("Senha atual inválida.");

        user.PasswordHash = _passwordHasher.Hash(request.NewPassword);
        user.MarkFirstAccessCompleted();
        await _users.SaveChangesAsync(cancellationToken);

        return true;
    }
}
'@

Set-Content "$rootPath/Authentication.Application/Features/Auth/Commands/ChangePasswordCommandHandler.cs" $handler

# ADICIONA METODO AO AUTHCONTROLLER
$authControllerPath = Join-Path $rootPath "Authentication.API\Controllers\AuthController.cs"

if (-not (Test-Path $authControllerPath))
{
    throw "AuthController nao encontrado: $authControllerPath"
}

$controllerContent = Get-Content $authControllerPath -Raw

if ($controllerContent -notmatch 'ChangePassword\s*\(')
{
    $changePasswordAction = @'

    [HttpPost("change-password")]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
    {
        var result = await _mediator.Send(new ChangePasswordCommand(request.Email, request.CurrentPassword, request.NewPassword));

        return Ok(new
        {
            Success = result
        });
    }
'@

    $lastBraceIndex = $controllerContent.LastIndexOf('}')

    if ($lastBraceIndex -lt 0)
    {
        throw "Nao foi possivel localizar o final da classe AuthController."
    }

    $updatedContent = $controllerContent.Substring(0, $lastBraceIndex) + $changePasswordAction + "`r`n}"

    Set-Content -LiteralPath $authControllerPath -Value $updatedContent -Encoding utf8

    Write-Host "Metodo ChangePassword adicionado ao AuthController." -ForegroundColor Green
}
else
{
    Write-Host "Metodo ChangePassword ja existe no AuthController." -ForegroundColor Yellow
}

# BUILD
$solution = Get-ChildItem -Path $rootPath -Filter "Authentication.slnx*" | Select-Object -First 1

if (-not $solution)
{
    throw "Authentication.slnx nao encontrada."
}

Write-Host "Executando Build para $targetFramework sem paralelismo..." -ForegroundColor Yellow

dotnet build $solution.FullName --framework $targetFramework -m:1
if ($LASTEXITCODE -ne 0) {
    throw "Build da solution Authentication falhou para $targetFramework."
}

Write-Host "Essa Fase foi concluida com sucesso." -ForegroundColor Green