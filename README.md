# Projeto e Scripts em Desenvolvimento ainda não concluído

# SaaS Enterprise Microsserviços

Automação da infraestrutura compartilhada e da estrutura inicial do microsserviço `Authentication` para uma plataforma SaaS. O projeto utiliza scripts PowerShell para provisionar Docker Swarm, Docker Secrets, SQL Server, RabbitMQ e uma solução .NET organizada em camadas.

> Este README descreve o comportamento atual dos scripts. Ele não representa funcionalidades futuras que ainda não foram implementadas ou integradas.

## Escopo atual

Os scripts automatizam:

- Docker Swarm e Docker Secrets;
- rede Docker overlay compartilhada;
- SQL Server 2022;
- RabbitMQ Management;
- solução `.slnx` do microsserviço `Authentication`;
- projetos API, Application, Domain, Infrastructure e Tests;
- entidades de usuário, role, permission e refresh token;
- persistência com Entity Framework Core e SQL Server;
- migration inicial;
- autenticação JWT;
- autorização baseada em roles e permissões;
- seed do usuário administrador;
- login;
- indicação de primeiro acesso;
- alteração da senha no primeiro acesso.

## Tecnologias

- PowerShell;
- .NET SDK detectado em tempo de execução;
- ASP.NET Core;
- Entity Framework Core;
- SQL Server 2022;
- Docker;
- Docker Swarm;
- Docker Secrets;
- RabbitMQ;
- MediatR;
- FluentValidation;
- JWT Bearer;
- BCrypt.Net-Next;
- xUnit v3;
- FluentAssertions;
- Moq.

## Pré-requisitos

Instale e disponibilize no `PATH`:

- Windows PowerShell ou PowerShell 7;
- Docker Desktop ou Docker Engine com suporte ao Docker Swarm;
- .NET SDK;
- acesso ao NuGet para restauração dos pacotes.

O usuário que executa os scripts precisa ter permissão para:

- executar comandos Docker;
- inicializar e administrar o Docker Swarm;
- criar e remover Docker Secrets;
- criar serviços, volumes e redes Docker;
- executar comandos `dotnet` e `dotnet ef`.

## Arquivos necessários para os secrets

Antes da Fase 1, crie na raiz do repositório os arquivos:

```text
secrets_sql_sa_password.txt
secrets_rabbitmq_password.txt
secrets_jwt_key.txt
```

Esses arquivos são utilizados para criar os secrets Docker:

```text
sql_sa_password
rabbitmq_password
jwt_key
```

Não versione esses arquivos nem suas senhas no repositório.

## Configuração da infraestrutura

A infraestrutura utiliza o arquivo `.env.base` na raiz do projeto. Os principais valores são:

```dotenv
DOCKER_NETWORK=infra_net
SQL_CONTAINER=sqlserver2022
SQL_VOLUME=sqlserver_data
SQL_PORT=1433
SQL_SERVER=localhost
SQL_SA_USER=sa
RABBIT_CONTAINER=rabbitmq
RABBIT_VOLUME=rabbitmq_data
RABBIT_PORT=5672
SPRING_RABBITMQ_HOST=rabbitmq
SPRING_RABBITMQ_USERNAME=admin_geral
```

A Fase 2 carrega essas variáveis durante a execução e utiliza os nomes configurados para criar a rede, os serviços e os volumes.

Para o SQL Server, a Fase 2 cria o alias local `sqlserver2022:2022` a partir da imagem oficial `mcr.microsoft.com/mssql/server:2022-latest` e remove a referência original após o alias ser criado. Assim, somente `sqlserver2022:2022` permanece listado. A Fase 0 remove ambos os nomes, além da imagem `authentication-api:local`.

A Fase 0 também lê esse arquivo para remover os mesmos recursos. Quando o `.env.base` não existe ou uma variável não está definida, são usados estes valores padrão:

```text
DOCKER_NETWORK=infra_net
SQL_CONTAINER=sqlserver2022
SQL_VOLUME=sqlserver_data
RABBIT_CONTAINER=rabbitmq
RABBIT_VOLUME=rabbitmq_data
```

## Ordem de execução

Execute os scripts na sequência abaixo, a partir da raiz do repositório:

```powershell
.\Fase-0-Cleanup.ps1
.\Fase-1-Criar-Secrets.ps1
.\Fase-2-Criar-Infrastructure.ps1
.\Fase-3-Criar-Authentication.ps1
.\Fase-4-Authentication-Packages.ps1
.\Fase-5-Authentication-Core.ps1
.\Fase-6-Authentication-Database.ps1
.\Fase-7-Authentication-JWT.ps1
.\Fase-8-Authentication-Seed.ps1
.\Fase-9-Authentication-Login.ps1
.\Fase-10-Authentication-ChangePassword.ps1
.\Fase-11-Deploy-Authentication.ps1
```

A Fase 0 é opcional e destrutiva. Utilize-a somente quando quiser remover a infraestrutura criada pelas Fases 1 e 2 e começar novamente.

Também é possível executar cada script individualmente, desde que os artefatos e pré-requisitos da fase anterior estejam disponíveis.

## Descrição das fases

### Fase 0 — limpeza

`Fase-0-Cleanup.ps1` remove, quando encontrados:

- serviços SQL Server e RabbitMQ;
- volumes SQL Server e RabbitMQ;
- secrets `sql_sa_password`, `rabbitmq_password` e `jwt_key`;
- rede overlay configurada.

A fase não cria recursos e não altera os arquivos da solução.

### Fase 1 — Docker Swarm e Docker Secrets

`Fase-1-Criar-Secrets.ps1`:

1. verifica a instalação e disponibilidade do Docker;
2. inicializa o Docker Swarm se ele estiver inativo;
3. valida o estado do Swarm;
4. valida os três arquivos de secrets;
5. cria os Docker Secrets quando eles ainda não existem.

### Fase 2 — infraestrutura compartilhada

`Fase-2-Criar-Infrastructure.ps1`:

- valida o Docker Swarm;
- carrega o `.env.base`;
- valida os secrets obrigatórios;
- cria a rede overlay;
- cria o serviço SQL Server 2022;
- cria o serviço RabbitMQ Management;
- monta os volumes configurados;
- aguarda o RabbitMQ responder na porta 5672;
- cria o usuário adicional configurado em `SPRING_RABBITMQ_USERNAME`;
- configura permissões do usuário RabbitMQ no vhost `/`.

Os serviços e a rede não são recriados quando já existem.

### Fase 3 — estrutura da solução Authentication

`Fase-3-Criar-Authentication.ps1` detecta o SDK estável mais recente disponível, ignorando versões `preview` e `rc`, e deriva o Target Framework no formato `netX.0`.

A estrutura criada é:

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

A fase também cria:

- referências entre os projetos;
- `appsettings.json`;
- `appsettings.Development.json`;
- `appsettings.Production.json`;
- `Authentication.API/Dockerfile`;
- `.dockerignore`;
- `docker-compose.yml`;
- `Authentication.TargetFramework.txt` na raiz do repositório, compartilhado pelas fases e por futuros microsserviços.

Ao final, executa restore e build da solução.

### Fase 4 — pacotes e dotnet-ef

`Fase-4-Authentication-Packages.ps1`:

- valida os projetos da solução;
- lê o Target Framework salvo pela Fase 3;
- instala ou atualiza o `dotnet-ef` quando necessário;
- mantém o `dotnet-ef` alinhado à major version do Target Framework;
- remove a referência antiga ao pacote `xunit` quando encontrada;
- adiciona ou alinha os pacotes NuGet da Application, Infrastructure, API e Tests.

Entre os pacotes configurados estão MediatR, FluentValidation, EF Core SQL Server, EF Core Design, BCrypt, RabbitMQ.Client, JWT Bearer, Swagger, health checks, xUnit v3, FluentAssertions, Moq e EF Core InMemory.

### Fase 5 — Core da Authentication

`Fase-5-Authentication-Core.ps1` valida as referências entre projetos e gera o núcleo da aplicação.

Entidades do Domain:

- `User`;
- `Role`;
- `Permission`;
- `RefreshToken`.

Abstrações e componentes da Application:

- `RoleNames`;
- `Permissions`;
- `JwtClaimNames`;
- `ITokenService`;
- `IPasswordHasher`;
- `TokenResult`;
- `ValidationBehavior`.

A entidade `User` possui, entre outros, os campos `Active`, `FirstAccess`, `CreatedAt`, `UpdatedAt` e `LastLoginAt`.

### Fase 6 — persistência e migration

`Fase-6-Authentication-Database.ps1` valida as entidades, os projetos, o Entity Framework Core e o `dotnet-ef`.

Gera em `Authentication.Infrastructure`:

- configurações Fluent API de User, Role, Permission e RefreshToken;
- `AuthenticationDbContext`;
- `DatabaseOptions`;
- `RabbitMqOptions`;
- `DatabaseExtensions`;
- `AuthenticationDbContextFactory` para design time.

O banco utilizado é:

```text
Db_Authentication
```

A conexão de runtime utiliza o Docker Secret `/run/secrets/sql_sa_password`. A factory de design time utiliza uma conexão local específica para permitir a geração da migration.

A fase executa build, cria a migration `InitialCreate` quando ela ainda não existe e executa novo build após a migration.

### Fase 7 — JWT e autorização

`Fase-7-Authentication-JWT.ps1` gera:

- `JwtOptions`;
- `SecretReader`;
- `PasswordHasher` baseado em BCrypt;
- `PermissionRequirement`;
- `PermissionAuthorizationHandler`;
- `PermissionPolicyProvider`;
- `TokenService`;
- `SecurityExtensions`;
- `Authentication.API/Program.cs`.

O `SecretReader` procura o segredo nesta ordem:

1. `/run/secrets/jwt_key`;
2. variável de ambiente `JWT_KEY`.

O JWT contém claims de subject, e-mail, primeiro acesso, tenant, role e permissões quando disponíveis.

A fase registra:

- autenticação JWT Bearer;
- autorização;
- MediatR;
- validators;
- pipeline de validação;
- banco de dados;
- health check;
- controllers;
- Swagger em ambiente de desenvolvimento.

O `TokenService` gera refresh tokens, mas a persistência desses tokens e o endpoint de renovação ainda não estão implementados.

### Fase 8 — seed inicial

`Fase-8-Authentication-Seed.ps1` gera `SeedData.cs`.

O seed:

- cria a role `Admin` caso ela não exista;
- cria o usuário `admin@local.com` caso ele não exista;
- utiliza inicialmente a senha `Admin@123`;
- gera o hash da senha com `PasswordHasher`;
- mantém `FirstAccess = true` por padrão.

O seed é idempotente. A fase gera o código e executa build, mas o script atual não chama automaticamente `SeedData.InitializeAsync` durante o startup da API.

### Fase 9 — login

`Fase-9-Authentication-Login.ps1` gera DTOs, command, validator, repositório, handler e controller.

Endpoint:

```http
POST /api/auth/login
```

Fluxo:

1. recebe e-mail e senha;
2. busca o usuário por e-mail;
3. carrega role e permissões;
4. verifica se o usuário está ativo;
5. valida a senha com BCrypt;
6. registra o último login;
7. gera o JWT;
8. retorna o token, a role e o indicador `FirstAccess`.

Exemplo de resposta:

```json
{
  "token": "...",
  "firstAccess": true,
  "role": "Admin"
}
```

### Fase 10 — alteração da senha

`Fase-10-Authentication-ChangePassword.ps1` gera a funcionalidade de troca de senha e adiciona o endpoint ao controller existente.

Endpoint:

```http
POST /api/auth/change-password
```

Regras da nova senha:

- mínimo de 8 caracteres;
- pelo menos uma letra maiúscula;
- pelo menos uma letra minúscula;
- pelo menos um número.

O handler:

1. localiza o usuário;
2. verifica a senha atual;
3. gera o hash da nova senha;
4. atualiza a senha;
5. executa `MarkFirstAccessCompleted()`;
6. salva a alteração;
7. retorna sucesso.

Atualmente o endpoint não exige que `FirstAccess` esteja `true`; ele pode ser usado para uma troca de senha comum desde que a senha atual seja válida.

## Arquitetura dos projetos

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

Responsabilidades:

- **Domain:** entidades e regras de estado do domínio;
- **Application:** DTOs, commands, handlers, validators, behaviors e interfaces;
- **Infrastructure:** persistência, repositories, JWT, BCrypt, secrets e implementações concretas;
- **API:** controllers, composição de dependências, autenticação, autorização, Swagger e health checks;
- **Tests:** projeto de testes criado pela Fase 3 e configurado pela Fase 4.

## Configuração gerada da API

O `appsettings.json` criado pela Fase 3 possui as seções:

- `Database`;
- `RabbitMQ`;
- `Jwt`;
- `HealthChecks`.

Os valores de servidor, host e usuário são inicialmente gerados vazios e precisam ser ajustados para o ambiente de execução. A Fase 2 cria a infraestrutura Docker, mas não preenche automaticamente esses campos do `appsettings.json`.

## Limitações atuais

Os scripts ainda não implementam completamente:

- aplicação automática das migrations no startup;
- execução automática do seed no startup;
- persistência dos refresh tokens;
- endpoint de refresh token;
- publicação e consumo de mensagens RabbitMQ pela aplicação;
- testes funcionais automatizados para login e troca de senha;
- deploy da API no Docker Swarm.

## Próximos microsserviços

Os microsserviços planejados para etapas futuras são:

- Tenancy;
- Notification.
