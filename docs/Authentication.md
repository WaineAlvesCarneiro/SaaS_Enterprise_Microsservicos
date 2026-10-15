# Authentication

## Responsabilidade

Authentication é o primeiro microsserviço da plataforma e centraliza login, emissão de JWT, refresh tokens, usuários, roles e a regra de troca de senha no primeiro acesso. Possui banco próprio (`Db_Authentication`) e não acessa bancos de outros serviços.

---

# Fluxos

## Login

```text
Email + senha
    ↓
Validação das credenciais
    ↓
JWT (e refresh token, conforme a implementação)
```

## Primeiro acesso e troca de senha

Todo usuário criado pelo seed, incluindo o Admin, começa com `FirstAccess = true`. A troca de senha bem-sucedida altera esse estado para `false`. A API deve exigir a troca antes de permitir o uso normal da conta.

## Seed inicial

Na inicialização da API, a sequência prevista é aplicar migrations e então criar a role Admin e o usuário Admin. O contexto define `admin@local.com` e `Admin@123` para esse usuário inicial. Essa credencial é apenas para o ambiente local de desenvolvimento; não deve ser reutilizada em produção. O usuário deve trocar a senha no primeiro acesso.

---

# JWT e multi-tenancy

O token é assinado com a chave disponibilizada pelo Docker Secret `jwt_key`. Como alternativa de configuração, o contexto define a variável de ambiente `JWT_KEY`. A chave não deve ser armazenada no código-fonte nem em arquivos versionados.

Quando o usuário estiver associado a um tenant, o JWT deve transportar o identificador usado pelos serviços para aplicar o isolamento. Serviços consumidores devem validar o token e não confiar em um `TenantId` enviado separadamente pelo cliente.

---

# Persistência

Banco: `Db_Authentication`.

Tabelas previstas no desenho inicial:

- Users
- Roles
- Permissions
- RefreshTokens

O modelo final e os mapeamentos serão definidos na Fase 5 (Core) e na Fase 6 (Database). A Fase 3 não cria entidades, DbContext, migrations, seed nem configuração JWT.

---

# Organização e fases

A solution `Authentication.slnx` fica em `Servicos/Authentication` e contém os projetos API, Application, Domain, Infrastructure e Tests.

A direção de dependência deve preservar a Clean Architecture: Application pode depender de Domain e de abstrações; Infrastructure implementa essas abstrações. Application não pode referenciar Infrastructure.

- Fase 3: estrutura da solution e build, sem instalar pacotes.
- Fase 4: pacotes.
- Fase 5: core e abstrações, sem DbContext.
- Fase 6: persistência, configurações e factory para migrations. Utiliza os Docker Secrets já existentes, sem recriá-los:
  - `sql_sa_password`
  - `rabbitmq_password`
  - `jwt_key`
- Fase 7: seed da role e do usuário Admin.
- Fase 8: serviço de tokens, claims e leitura do secret.
- Fase 9: fluxo de login.
- Fase 10: troca de senha.
