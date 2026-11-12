# Endpoints da API

## Base

O controller de autenticação utiliza a rota base:

```text
/api/auth
```

## Login

```http
POST /api/auth/login
Content-Type: application/json
```

Request:

```json
{
  "email": "admin@local.com",
  "password": "Admin@123"
}
```

Response conceitual:

```json
{
  "token": "<jwt>",
  "firstAccess": true,
  "role": "Admin"
}
```

O token é gerado pelo `TokenService`. O valor de `firstAccess` informa ao cliente que o usuário ainda não concluiu a troca da senha inicial.

## Alteração de senha

```http
POST /api/auth/change-password
Content-Type: application/json
```

Request:

```json
{
  "email": "admin@local.com",
  "currentPassword": "Admin@123",
  "newPassword": "NovaSenha@123"
}
```

Response conceitual:

```json
{
  "success": true
}
```

Regras da nova senha:

- mínimo de 8 caracteres;
- uma letra maiúscula;
- uma letra minúscula;
- um número.

## Health check

O `Program.cs` gerado registra:

```http
GET /health
```

A resposta depende da disponibilidade e configuração do `AuthenticationDbContext`.

## Swagger

Swagger e Swagger UI são registrados para ambiente de desenvolvimento. O caminho final depende da configuração padrão do ASP.NET Core e da versão dos pacotes instalados.

## Erros esperados

O fluxo de login ou troca de senha pode falhar quando:

- o usuário não existe;
- o usuário está inativo;
- a senha atual é inválida;
- o banco não está acessível;
- o secret JWT ou SQL não está disponível;
- a validação do request falha.

## Endpoints ainda não disponíveis

Os scripts atuais não geram endpoints para:

- refresh token;
- logout ou revogação de token;
- cadastro de usuários;
- administração de roles;
- administração de permissões;
- recuperação de senha.
