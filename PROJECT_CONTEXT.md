# SaaS Enterprise Microsserviços

## Objetivo

Este repositório automatiza a criação inicial da infraestrutura compartilhada e do microsserviço `Authentication` de uma plataforma SaaS. A automação é feita por scripts PowerShell que criam projetos, arquivos de configuração, código-base, persistência, segurança JWT, login e troca de senha no primeiro acesso.

O documento descreve o comportamento implementado pelos scripts. Ele não representa funcionalidades futuras que ainda não estejam geradas ou integradas ao serviço.

## Escopo atual

O fluxo automatizado cobre:

- Docker Swarm e Docker Secrets;
- rede overlay compartilhada;
- SQL Server e RabbitMQ como infraestrutura externa aos microsserviços;
- solução `.slnx` do microsserviço `Authentication`;
- projetos API, Application, Domain, Infrastructure e Tests;
- entidades de usuário, papel, permissão e refresh token;
- Entity Framework Core, SQL Server, DbContext, configurações e migration inicial;
- autenticação JWT e autorização por permissões;
- seed de papel e usuário administrador;
- login;
- indicação de primeiro acesso;
- alteração da senha no primeiro acesso.

O escopo ainda não cobre completamente:

- persistência de refresh tokens gerados pelo `TokenService`;
- endpoint de renovação de token;
- publicação ou consumo efetivo de mensagens RabbitMQ pela aplicação;
- aplicação automática da migration e execução automática do seed durante o startup da API;
- deploy do serviço `Authentication.API` no Docker Swarm.

## Tecnologias

- PowerShell;
- .NET SDK detectado em tempo de execução;
- ASP.NET Core;
- SQL Server 2022;
- Entity Framework Core;
- Docker;
- Docker Swarm;
- Docker Secrets;
- RabbitMQ;
- MediatR;
- FluentValidation;
- JWT Bearer;
- BCrypt.Net-Next;
- xUnit v3, FluentAssertions, Moq e EF Core InMemory para testes.

## Convenções de execução

Os scripts devem ser executados a partir da raiz do repositório, na ordem abaixo. Cada fase posterior depende de artefatos produzidos pelas fases anteriores.

```text
Fase-0-Cleanup.ps1
Fase-1-Criar-Secrets.ps1
Fase-2-Criar-Infrastructure.ps1
Fase-3-Criar-Authentication.ps1
Fase-4-Authentication-Packages.ps1
Fase-5-Authentication-Core.ps1
Fase-6-Authentication-Database.ps1
Fase-7-Authentication-JWT.ps1
Fase-8-Authentication-Seed.ps1
Fase-9-Authentication-Login.ps1
Fase-10-Authentication-ChangePassword.ps1
Fase-11-Deploy-Authentication.ps1
```

A Fase 0 é opcional e destrutiva: remove recursos da infraestrutura. Ela deve ser usada apenas quando for necessário reinicializar o ambiente.

Os scripts usam `$PSScriptRoot` para localizar arquivos do repositório. As fases de geração utilizam validações de existência e, em vários casos, não sobrescrevem arquivos existentes com conteúdo diferente.

## Configuração da infraestrutura

O arquivo `.env.base` é utilizado pela Fase 2 e contém, entre outras, estas variáveis:

```dotenv
DOCKER_NETWORK=infra_net
SQL_CONTAINER=sqlserver2022
SQL_VOLUME=sqlserver_data
SQL_PORT=1433
SQL_SERVER=localhost
RABBIT_CONTAINER=rabbitmq
RABBIT_VOLUME=rabbitmq_data
RABBIT_PORT=5672
SPRING_RABBITMQ_HOST=rabbitmq
SPRING_RABBITMQ_USERNAME=admin_geral
```

A Fase 0 também lê `.env.base` para remover os mesmos serviços, volumes e rede. Se o arquivo não existir ou alguma variável estiver ausente, são usados estes fallbacks:

```text
SQL_CONTAINER   = sqlserver2022
RABBIT_CONTAINER = rabbitmq
SQL_VOLUME      = sqlserver_data
RABBIT_VOLUME   = rabbitmq_data
DOCKER_NETWORK  = infra_net
```

A Fase 2 carrega as variáveis do `.env.base` apenas no processo atual do script. Isso não transforma o arquivo em uma configuração global permanente do sistema.

O serviço SQL Server utiliza somente a tag local `sqlserver2022:2022`, criada a partir de `mcr.microsoft.com/mssql/server:2022-latest`; a referência original é removida depois do alias ser criado. A Fase 0 remove a tag local, a imagem oficial e `authentication-api:local`.

## Fase 0 — limpeza

`Fase-0-Cleanup.ps1` remove, quando encontrados:

- serviços Docker `SQL_CONTAINER` e `RABBIT_CONTAINER`;
- volumes `SQL_VOLUME` e `RABBIT_VOLUME`;
- secrets `sql_sa_password`, `rabbitmq_password` e `jwt_key`;
- rede overlay `DOCKER_NETWORK`.

A limpeza não cria recursos e não altera arquivos da solução.

## Fase 1 — Docker Swarm e secrets

`Fase-1-Criar-Secrets.ps1`:

1. verifica se o comando `docker` está disponível;
2. verifica se o Docker está acessível;
3. inicializa o Docker Swarm quando ele estiver inativo;
4. valida o estado do Swarm;
5. procura, na raiz do repositório, os arquivos:
   - `secrets_sql_sa_password.txt`;
   - `secrets_rabbitmq_password.txt`;
   - `secrets_jwt_key.txt`;
6. cria os Docker Secrets abaixo caso ainda não existam:
   - `sql_sa_password`;
   - `rabbitmq_password`;
   - `jwt_key`.

Os secrets existentes não são recriados.

## Fase 2 — infraestrutura compartilhada

`Fase-2-Criar-Infrastructure.ps1`:

- valida o Docker e o Docker Swarm;
- carrega `.env.base`;
- valida os três secrets obrigatórios;
- cria a rede overlay configurada em `DOCKER_NETWORK`;
- cria o serviço SQL Server 2022 com o secret `sql_sa_password` e o volume configurado;
- cria o serviço RabbitMQ Management com o secret `rabbitmq_password` e o volume configurado;
- publica as portas 1433, 5672 e 15672 conforme os comandos do script;
- aguarda o RabbitMQ responder na porta 5672;
- cria o usuário adicional configurado em `SPRING_RABBITMQ_USERNAME`;
- atribui ao usuário RabbitMQ a tag `administrator` e permissões no vhost `/`.

Os serviços e a rede não são recriados quando já existem.

## Fase 3 — estrutura do microsserviço Authentication

`Fase-3-Criar-Authentication.ps1` detecta o SDK estável mais recente disponível, ignorando versões `preview` e `rc`, e deriva o Target Framework no formato `netX.0`.

A fase cria:

```text
Servicos/
└── Authentication/
    ├── Authentication.slnx
    ├── Authentication.API/
    ├── Authentication.Application/
    ├── Authentication.Domain/
    ├── Authentication.Infrastructure/
    └── Authentication.Tests/
```

Também cria e configura:

- referências entre projetos;
- `appsettings.json`;
- `appsettings.Development.json`;
- `appsettings.Production.json`;
- `Authentication.API/Dockerfile`;
- `.dockerignore`;
- `docker-compose.yml` com a rede externa `infra_net`;
- `Authentication.TargetFramework.txt` na raiz do repositório, compartilhado pelas fases e por futuros microsserviços.

A fase remove arquivos padrão dos templates, restaura a solução e executa build.

## Fase 4 — pacotes e dotnet-ef

`Fase-4-Authentication-Packages.ps1`:

- valida os projetos gerados;
- lê o Target Framework salvo pela Fase 3;
- garante que `dotnet-ef` esteja instalado e alinhado à major version do Target Framework;
- remove referências antigas ao pacote `xunit` quando necessário;
- adiciona ou alinha os pacotes NuGet da Application, Infrastructure, API e Tests;
- utiliza a mesma major version para EF Core, `dotnet-ef` e pacotes ASP.NET Core correspondentes;
- valida a solution `.slnx`.

Entre os pacotes configurados estão MediatR, FluentValidation, EF Core SQL Server, EF Core Design, BCrypt, RabbitMQ.Client, JWT Bearer, Swagger, health checks, xUnit v3, FluentAssertions, Moq e EF Core InMemory.

## Fase 5 — Core da Authentication

`Fase-5-Authentication-Core.ps1` valida referências e regras básicas da arquitetura antes de gerar os arquivos.

### Projetos e dependências

```text
Authentication.API
    -> Authentication.Application
    -> Authentication.Infrastructure

Authentication.Application
    -> Authentication.Domain

Authentication.Infrastructure
    -> Authentication.Application
    -> Authentication.Domain

Authentication.Tests
    -> Authentication.Application

Authentication.Domain
    -> nenhum projeto interno
```

A Application não referencia Infrastructure. O Domain não referencia outros projetos.

### Código gerado

No Domain:

- `User`;
- `Role`;
- `Permission`;
- `RefreshToken`.

Na Application:

- `RoleNames`;
- `Permissions`;
- `JwtClaimNames`;
- `ITokenService`;
- `IPasswordHasher`;
- `TokenResult`;
- `ValidationBehavior`.

A entidade `User` possui, entre outros, `Active`, `FirstAccess`, `CreatedAt`, `UpdatedAt` e `LastLoginAt`. A alteração de `FirstAccess` para `false` ocorre através de `MarkFirstAccessCompleted()`.

## Fase 6 — persistência e migration

`Fase-6-Authentication-Database.ps1` valida:

- a solution;
- o projeto Infrastructure;
- as entidades geradas;
- os pacotes EF Core Design e SQL Server;
- o alinhamento das versões do Target Framework, EF Core e `dotnet-ef`.

Gera em Infrastructure:

- configurações Fluent API de User, Role, Permission e RefreshToken;
- `AuthenticationDbContext`;
- `DatabaseOptions`;
- `RabbitMqOptions`;
- `DatabaseExtensions`;
- `AuthenticationDbContextFactory` para design time.

O banco configurado é `Db_Authentication`. A conexão de runtime utiliza o secret `/run/secrets/sql_sa_password` e SQL Server. A factory de design time usa uma conexão local própria para permitir a geração da migration.

A fase executa build, cria a migration `InitialCreate` quando ela ainda não existir e executa novo build após a migration.

## Fase 7 — JWT e autorização

`Fase-7-Authentication-JWT.ps1` gera os componentes de segurança:

- `JwtOptions`;
- `SecretReader`;
- `PasswordHasher` baseado em BCrypt com work factor 12;
- `PermissionRequirement`;
- `PermissionAuthorizationHandler`;
- `PermissionPolicyProvider`;
- `TokenService`;
- `SecurityExtensions`.

O `SecretReader` procura primeiro o Docker Secret `/run/secrets/jwt_key` e depois a variável de ambiente `JWT_KEY`.

O `TokenService` cria access token JWT com:

- subject do usuário;
- e-mail;
- claim `first_access`;
- claim `tenant_id`, quando houver tenant;
- role;
- permissões.

Os tempos padrão definidos no código são 60 minutos para access token e 30 dias para refresh token, enquanto os valores efetivos podem ser configurados pelo bloco `Jwt` do `appsettings.json`.

A fase também sobrescreve `Authentication.API/Program.cs` para registrar:

- controllers;
- Swagger em Development;
- banco de dados;
- segurança JWT;
- MediatR;
- validators;
- pipeline de validação;
- health check do DbContext;
- autenticação e autorização;
- endpoint `/health`.

O refresh token é gerado pelo `TokenService`, mas sua persistência e seu endpoint de renovação ainda não estão implementados.

## Fase 8 — seed

`Fase-8-Authentication-Seed.ps1` gera `Authentication.Infrastructure/Seed/SeedData.cs`.

O seed é idempotente e:

1. cria a role `Admin` caso ela não exista;
2. cria o usuário `admin@local.com` caso ele não exista;
3. usa a senha inicial `Admin@123`;
4. gera o hash da senha com `PasswordHasher`;
5. cria o usuário com `FirstAccess = true` por padrão.

A fase executa build após gerar o arquivo.

O script gera a classe de seed, mas o código atual não chama `SeedData.InitializeAsync` automaticamente no startup da API. A execução automática do seed ainda precisa ser integrada ao pipeline de inicialização da aplicação.

## Fase 9 — login

`Fase-9-Authentication-Login.ps1` gera:

- `LoginRequest`;
- `LoginResponse`;
- `LoginCommand`;
- `LoginCommandValidator`;
- `IUserRepository`;
- `UserRepository`;
- `LoginCommandHandler`;
- `AuthController`.

O endpoint criado é:

```http
POST /api/auth/login
```

O login:

1. recebe e-mail e senha;
2. busca o usuário por e-mail;
3. carrega role e permissões;
4. valida se o usuário está ativo;
5. verifica a senha com BCrypt;
6. registra o último login;
7. gera o JWT;
8. retorna token, role e `FirstAccess`.

Resposta conceitual:

```json
{
  "token": "...",
  "firstAccess": true,
  "role": "Admin"
}
```

## Fase 10 — alteração da senha no primeiro acesso

`Fase-10-Authentication-ChangePassword.ps1` gera:

- `ChangePasswordRequest`;
- `ChangePasswordCommand`;
- `ChangePasswordCommandValidator`;
- `ChangePasswordCommandHandler`.

O endpoint adicionado ao `AuthController` é:

```http
POST /api/auth/change-password
```

A validação exige:

- e-mail válido;
- senha atual preenchida;
- nova senha com no mínimo 8 caracteres;
- letra maiúscula;
- letra minúscula;
- número.

O handler:

1. localiza o usuário;
2. verifica a senha atual;
3. gera o hash da nova senha;
4. atualiza `PasswordHash`;
5. chama `MarkFirstAccessCompleted()`;
6. persiste a alteração;
7. retorna sucesso.

A alteração de senha não exige atualmente que `FirstAccess` esteja `true`; o método também pode ser chamado para uma troca de senha comum, desde que o e-mail e a senha atual sejam válidos.

## Arquitetura dos projetos

### Domain

Contém entidades e regras de estado do domínio. Não deve depender de EF Core, SQL Server, RabbitMQ, JWT, Docker ou ASP.NET Core.

### Application

Contém DTOs, commands, handlers, validators, behaviors e interfaces. O login e a troca de senha são implementados com MediatR e dependem de abstrações como `IUserRepository`, `IPasswordHasher` e `ITokenService`.

### Infrastructure

Contém persistência, configurações EF Core, repositories, implementação do hash de senha, JWT, leitura de secrets e registro de dependências.

### API

Contém controllers, composição da aplicação, Swagger, autenticação, autorização e health check.

### Tests

É criado como projeto xUnit e recebe as dependências de teste configuradas pela Fase 4. Os scripts atuais não geram testes funcionais para login ou troca de senha.

## Configuração gerada da API

O `appsettings.json` criado pela Fase 3 contém as seções:

- `Database`;
- `RabbitMQ`;
- `Jwt`;
- `HealthChecks`.

Os valores de servidor, host e usuário são inicialmente vazios no arquivo gerado e precisam ser configurados para o ambiente de execução. A Fase 2 cria a infraestrutura Docker, mas não atualiza automaticamente esses campos do `appsettings.json`.

## Regras de manutenção

Ao alterar os scripts:

- preservar a ordem das fases;
- validar pré-requisitos antes de gerar arquivos;
- não sobrescrever arquivos existentes com conteúdo diferente quando a fase já possui essa proteção;
- manter as referências entre projetos compatíveis com a arquitetura acima;
- manter EF Core e `dotnet-ef` alinhados ao Target Framework detectado;
- preservar a leitura de Docker Secrets para SQL Server e JWT;
- não documentar como concluída uma funcionalidade que o script apenas gera, mas não integra ou executa;
- validar a sintaxe PowerShell dos scripts alterados;
- executar build quando a fase correspondente gerar ou alterar código C#.

## Estado atual

As Fases 0 a 10 estão implementadas como scripts de geração e provisionamento. A execução completa depende de Docker, Docker Swarm, arquivos de secrets, SDK .NET, acesso ao NuGet e configuração dos arquivos gerados para o ambiente.

A arquitetura de autenticação está gerada até a troca de senha no primeiro acesso, mas a integração automática do seed, a persistência de refresh tokens, a renovação de tokens, os testes funcionais e o deploy da API ainda são etapas posteriores.

## Próximos microsserviços

Os microsserviços planejados posteriormente são:

- Tenancy;
- Notification.

Eles não são criados pelos scripts atuais.