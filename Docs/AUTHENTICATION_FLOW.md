# Fluxo de autenticação

## Visão geral

O fluxo atual cobre:

1. criação do usuário administrador pelo seed;
2. login com e-mail e senha;
3. geração de JWT;
4. retorno do indicador de primeiro acesso;
5. alteração da senha;
6. marcação do primeiro acesso como concluído.

## Seed do administrador

A Fase 8 gera `SeedData.cs`. A classe verifica se a role e o usuário já existem antes de criá-los.

Dados iniciais:

```text
E-mail: admin@local.com
Senha: Admin@123
Role: Admin
FirstAccess: true
```

A senha é armazenada como hash BCrypt. O código do seed é gerado e compilado, mas não é chamado automaticamente pelo startup atual da API.

## Login

O endpoint `POST /api/auth/login` recebe e-mail e senha. O handler:

1. remove espaços do e-mail;
2. busca o usuário por e-mail;
3. carrega role e permissões;
4. verifica `Active`;
5. valida a senha com `IPasswordHasher`;
6. registra `LastLoginAt`;
7. gera o access token;
8. retorna `Token`, `FirstAccess` e `Role`.

Credenciais inválidas resultam em `UnauthorizedAccessException`.

## JWT

O `TokenService` gera um access token com claims de:

- subject;
- e-mail;
- `first_access`;
- `tenant_id`, quando informado;
- role;
- permissões.

A chave é lida nesta ordem:

1. `/run/secrets/jwt_key`;
2. variável de ambiente `JWT_KEY`.

As opções de issuer, audience, duração do access token e duração do refresh token vêm da seção `Jwt` da configuração, com valores padrão na classe `JwtOptions`.

## Primeiro acesso

O login devolve `FirstAccess = true` para o usuário administrador recém-criado. O cliente pode usar essa informação para direcionar o usuário à troca de senha.

## Alteração da senha

O endpoint `POST /api/auth/change-password` recebe:

- e-mail;
- senha atual;
- nova senha.

O handler valida a senha atual, gera o novo hash, salva a alteração e chama `MarkFirstAccessCompleted()`. Esse método define `FirstAccess = false` e atualiza `UpdatedAt`.

Atualmente o endpoint não verifica se `FirstAccess` ainda está `true`; portanto, também pode ser utilizado para uma troca de senha comum.

## Autorização

A Fase 7 gera um `PermissionRequirement`, um handler e um provider de políticas dinâmicas. As permissões do usuário são adicionadas ao JWT como claims `permission` e podem ser utilizadas pelas políticas de autorização.

## O que ainda não está implementado

- persistência dos refresh tokens gerados;
- endpoint de refresh token;
- revogação de refresh token pelo fluxo HTTP;
- execução automática do seed no startup;
- aplicação automática das migrations no startup.
