# SaaS Enterprise Microsserviços

## Objetivo

Desenvolver e aprender arquitetura de microsserviços construindo uma plataforma SaaS.

A prioridade não é apenas criar um sistema funcional.

O objetivo principal é entender:

- Clean Architecture
- Microsserviços
- CQRS
- Entity Framework Core
- JWT
- RabbitMQ
- Docker
- Docker Swarm
- Docker Secrets
- Multi-Tenancy
- Escalabilidade
- Evolução arquitetural
- Manutenção de longo prazo

---

## Política de Versionamento

Nenhum script PowerShell, arquivo .csproj, documento .md ou código-fonte pode conter versões hardcoded de:

- .NET
- Entity Framework Core
- dotnet-ef

Todos os scripts devem detectar automaticamente a versão estável mais recente do SDK .NET disponível durante a execução.

### Regras Obrigatórias

- Utilizar sempre a versão estável mais recente do SDK .NET.
- Nunca utilizar Preview.
- Nunca utilizar RC (Release Candidate).
- Nunca utilizar Nightly.
- Nunca utilizar dependências Microsoft em versões pré-lançamento.
- A versão deve ser detectada em tempo de execução.
- Os scripts não podem depender da documentação para definir versões.
- O TargetFramework deve ser derivado automaticamente da versão detectada.
- O Entity Framework Core deve utilizar a mesma major version do TargetFramework.
- O dotnet-ef deve utilizar a mesma major version do TargetFramework.
- Nenhum script pode assumir que a versão atual seja específica.
- Os exemplos abaixo servem apenas para ilustrar a regra.

### Exemplo Conceitual

```text
SDK estável X.x
↓
netX.0
↓
EF Core X.*
↓
dotnet-ef X.*
```

---

## Regras para Geração de Scripts

- Nunca presumir que uma fase anterior executou corretamente.
- Sempre validar pré-requisitos.
- Não sobrescrever arquivos existentes sem validação.
- Não remover arquivos existentes sem justificativa.
- Revisar referências entre projetos antes de concluir uma fase.
- Priorizar estabilidade.
- Priorizar simplicidade.
- Priorizar consistência arquitetural.

### Regras para Geração de Código

- Não criar abstrações desnecessárias.
- Não criar código especulativo para fases futuras.
- Não introduzir padrões que não estejam definidos neste documento.
- Não antecipar funcionalidades de fases posteriores.

---

## Stack Tecnológica

```text
.NET (detectado automaticamente)

SQL Server

RabbitMQ

Docker

Docker Swarm

Docker Secrets

Entity Framework Core

MediatR

FluentValidation
```

---

## Infraestrutura Existente

Já criada.

Não deve ser recriada pelos microsserviços.

### Docker Secrets

```text
sql_sa_password

rabbitmq_password

jwt_key
```

Criados pela:

```text
Fase-1-Criar-Secrets.ps1
```

### Infraestrutura Compartilhada

#### Docker Swarm

```text
Já configurado
```

#### Rede

```text
infra_net
```

#### SQL Server

```text
Container:
sqlserver2022
```

#### RabbitMQ

```text
Container:
rabbitmq
```

Criado pela:

```text
Fase-2-Criar-Infrastructure.ps1
```

---

## Regras Gerais

- Uma Solution por microsserviço.
- Utilizar .slnx.
- Um docker-compose por microsserviço.
- SQL Server e RabbitMQ ficam fora dos microsserviços.
- JWT deve utilizar Docker Secrets.
- O Seed deve criar o usuário administrador.
- Todo usuário criado pelo Seed deve trocar a senha no primeiro acesso.

---

## Regras Rígidas de Clean Architecture

A arquitetura definida neste documento é obrigatória.

A IA não pode alterá-la sem justificativa técnica explícita.

### Referências entre Projetos

#### Permitidas

```text
Authentication.API
    → Authentication.Application

Authentication.Application
    → Authentication.Domain

Authentication.Infrastructure
    → Authentication.Application
    → Authentication.Domain

Authentication.Domain
    → Nenhuma referência interna

Authentication.Tests
    → Livre para testes
```

#### Proibidas

```text
Application → Infrastructure

Domain → Application

Domain → Infrastructure

Domain → API

Infrastructure → API
```

Exemplo proibido:

```csharp
using Authentication.Infrastructure.Persistence;
```

dentro da camada Application.

### Domain

Pode conter:

- Entidades
- Value Objects
- Enums
- Regras de negócio
- Interfaces de domínio

Não pode conter:

- Entity Framework
- DbContext
- SQL Server
- RabbitMQ
- JWT
- Docker
- IConfiguration
- ILogger
- HttpContext
- Controllers
- Handlers
- Dependências de infraestrutura

### Application

Pode conter:

- Commands
- Queries
- Handlers
- Validators
- Behaviors
- DTOs
- Interfaces

Não pode conter:

- DbContext
- Entity Framework
- SQL
- RabbitMQ
- Controllers
- Implementações concretas

Application deve trabalhar exclusivamente através de abstrações.

### Infrastructure

Pode conter:

- DbContext
- Repositories
- JWT
- RabbitMQ
- SQL Server
- Integrações externas
- Serviços concretos
- Implementações de interfaces

### API

Pode conter:

- Controllers
- Endpoints
- Middleware
- Swagger
- OpenAPI
- Dependency Injection

Não pode conter:

- Regras de negócio
- SQL
- Entity Framework
- RabbitMQ
- Implementações complexas

Controllers devem delegar o processamento para a camada Application.

### Dependency Injection

Toda composição de dependências deve ocorrer na camada API.

Application não registra serviços.

Domain não registra serviços.

Infrastructure expõe métodos de extensão para registro.

API compõe a aplicação.

### CQRS

Commands:

- Alteram estado.
- Não retornam entidades do Domain.

Queries:

- Consultam dados.
- Não alteram estado.

Handlers:

- Contêm apenas o fluxo da aplicação.
- Não devem conter regras de negócio complexas.

Regras de negócio pertencem ao Domain.

### DTOs

Controllers não devem expor entidades do Domain.

API e Application devem utilizar DTOs próprios.

### Entity Framework

DbContext deve existir apenas em:

```text
Authentication.Infrastructure
```

É proibido criar DbContext em:

```text
Authentication.API

Authentication.Application

Authentication.Domain
```

### Migrations

Todas as migrations devem existir apenas em:

```text
Authentication.Infrastructure
```

### Proibido no Domain

```csharp
[Table]
[Column]
[Key]
[ForeignKey]
```

O mapeamento deve utilizar Fluent API.

### Eventos

Eventos de integração pertencem à camada Application.

RabbitMQ deve ser utilizado através de abstrações.

A implementação da publicação e consumo deve permanecer na Infrastructure.

### Banco de Dados

Cada microsserviço possui banco próprio.

É proibido:

- Compartilhar tabelas entre microsserviços.
- Acessar diretamente o banco de outro microsserviço.

Comunicação entre microsserviços:

- APIs
- RabbitMQ

### Seed

O Seed:

- Deve ser idempotente.
- Não pode gerar registros duplicados.
- Não pode ser executado antes das migrations.

### Regra Final de Arquitetura

Em caso de dúvida:

- Favorecer baixo acoplamento.
- Favorecer inversão de dependência.
- Favorecer separação de responsabilidades.
- Não criar atalhos arquiteturais.
- Não quebrar Clean Architecture para facilitar implementação.

---

## Authentication

Primeiro microsserviço da plataforma.

Responsável por:

```text
Login

JWT

Refresh Token

Roles

Usuários

Primeiro Acesso
```

### Banco

```text
Db_Authentication
```

### Usuário Administrador

Ao iniciar a aplicação:

```text
Migrations
↓
Seed
↓
Criar Role Admin
↓
Criar Usuário Admin
```

#### Usuário padrão

```text
Email:
admin@local.com

Senha:
Admin@123
```

#### Primeiro acesso

```csharp
FirstAccess = true;
```

Após alteração de senha:

```csharp
FirstAccess = false;
```

### JWT

Utilizar:

```text
Docker Secret

jwt_key
```

Fallback:

```text
JWT_KEY
```

---

## Roadmap

```text
Fase-1  ✅ Secrets

Fase-2  ✅ Infrastructure

Fase-3  ⏳ Authentication Structure

Fase-4  ⏳ Packages

Fase-5  ⏳ Core

Fase-6  ⏳ Database

Fase-7  ⏳ Seed

Fase-8  ⏳ JWT

Fase-9  ⏳ Login

Fase-10 ⏳ Change Password
```

---

## Ordem das Fases

### Fase-3

Responsabilidade:

```text
Estrutura da Solution
```

Objetivo:

```text
dotnet build
```

Não criar:

- Entidades
- JWT
- DbContext
- Migrations
- Seed

### Fase-4

Responsabilidade:

```text
Pacotes
```

Validar:

- dotnet-ef compatível com o TargetFramework detectado.
- Sem versões fixas.
- Sem Preview.
- Sem RC.
- Sem Nightly.

Objetivo:

```text
dotnet build
```

### Fase-5

Responsabilidade:

```text
Core
```

Criar:

```text
User

Role

RefreshToken

IPasswordHasher

ITokenService

ValidationBehavior
```

Sem DbContext.

### Fase-6

Responsabilidade:

```text
Persistence
```

Criar:

```text
AuthenticationDbContext

Configurations

DatabaseExtensions

DbContextFactory
```

Objetivo:

```text
dotnet ef migrations add InitialCreate
```

### Fase-7

Responsabilidade:

```text
Seed
```

Criar:

```text
Role Admin

Admin User
```

### Fase-8

Responsabilidade:

```text
JWT
```

Criar:

```text
TokenService

Claims

SecretReader
```

### Fase-9

Responsabilidade:

```text
Login
```

Criar:

```text
LoginCommand

LoginValidator

LoginHandler

AuthenticationController
```

### Fase-10

Responsabilidade:

```text
Change Password
```

---

## Estado Atual

Os rascunhos existentes das fases abaixo devem ser revisados do zero:

```text
Fase-3
Fase-4
Fase-5
Fase-6
Fase-7
Fase-8
Fase-9
```

---

## Regra de Consistência

Toda informação deste documento tem prioridade sobre:

- Scripts existentes
- Documentação anterior
- Exemplos antigos

Em caso de conflito:

1. Seguir Clean Architecture.
2. Seguir este documento.
3. Reportar o conflito.
4. Não assumir comportamento implícito.

---

## Próximos Microsserviços

```text
Tenancy

Notification
```