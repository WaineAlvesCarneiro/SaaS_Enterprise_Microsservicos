# Arquitetura

## Visão geral

O microsserviço `Authentication` utiliza uma separação em camadas baseada em Clean Architecture:

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

A composição das dependências ocorre na API por meio de métodos de extensão expostos pela Infrastructure.

## Projetos

### Authentication.Domain

Contém as entidades e regras de estado do domínio:

- `User`;
- `Role`;
- `Permission`;
- `RefreshToken`.

A entidade `User` controla, entre outros dados, `Active`, `FirstAccess`, `CreatedAt`, `UpdatedAt` e `LastLoginAt`.

### Authentication.Application

Contém:

- DTOs;
- commands;
- handlers;
- validators;
- behaviors do MediatR;
- interfaces;
- modelos de resposta.

As principais abstrações são `IUserRepository`, `IPasswordHasher` e `ITokenService`.

### Authentication.Infrastructure

Contém:

- `AuthenticationDbContext`;
- configurações Fluent API;
- repositories;
- integração com SQL Server;
- geração e validação de JWT;
- BCrypt;
- leitura de Docker Secrets;
- registro de dependências;
- factory de design time do DbContext.

### Authentication.API

Contém:

- controllers;
- configuração do host;
- autenticação e autorização;
- Swagger em Development;
- health check;
- composição de dependências.

### Authentication.Tests

É criado como projeto de testes e recebe as dependências configuradas na Fase 4. Os scripts atuais não geram testes funcionais de login ou troca de senha.

## Estrutura gerada

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

## Persistência

O banco da Authentication é `Db_Authentication`. As migrations ficam em `Authentication.Infrastructure` e o mapeamento das entidades utiliza Fluent API.

## Comunicação externa

A infraestrutura provisiona RabbitMQ, mas a aplicação atual ainda não possui publicação ou consumo efetivo de mensagens.
