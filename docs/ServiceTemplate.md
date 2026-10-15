# Template de Microsserviço

## Estrutura padrão

Cada serviço fica em uma pasta própria dentro de `Servicos`, possui uma solution `.slnx` e projetos separados por camada.

```text
Servicos/
└── NomeServico/
    ├── NomeServico.slnx
    ├── NomeServico.API/
    ├── NomeServico.Application/
    ├── NomeServico.Domain/
    ├── NomeServico.Infrastructure/
    └── NomeServico.Tests/
```

A plataforma inicial prevê `Authentication`, `Tenancy` e `Notification`. Um Worker pode ser adicionado quando um caso de uso justificar processamento em background.

A stack base é .NET (versão estável detectada automaticamente), SQL Server, Entity Framework Core, MediatR, FluentValidation, RabbitMQ e Docker. Os pacotes são adicionados na fase própria, depois da estrutura inicial.

---

# API

Responsabilidades:

- Endpoints/controllers, middlewares e composição da aplicação.
- Configuração de autenticação, autorização e documentação da API conforme as fases do serviço.

Não deve concentrar regras de negócio nem acesso direto à persistência/Entity Framework.

A API pode referenciar Application e Infrastructure para registrar implementações no composition root.

---

# Application

Responsabilidades:

- Casos de uso, Commands, Queries, DTOs, validação e handlers.
- Definir interfaces/abstrações necessárias aos casos de uso.

Application pode referenciar Domain, mas não pode referenciar Infrastructure. Infrastructure implementa as abstrações requeridas.

---

# Domain

Responsabilidades:

- Entidades, value objects, enums e regras de negócio.

Domain não conhece Application, banco de dados, RabbitMQ, APIs externas ou detalhes de framework.

---

# Infrastructure

Responsabilidades:

- Persistência e DbContext, repositórios, integrações externas e mensageria.
- Implementar interfaces definidas pelas camadas internas.

Infrastructure pode referenciar Application e Domain; as camadas internas não podem depender dela.

---

# Dependências entre projetos

```text
Domain                 (sem dependências de outras camadas)
Application -> Domain
Infrastructure -> Application + Domain
API -> Application + Infrastructure
Tests -> Application (e outras camadas somente quando o teste exigir)
```

A direção deve ser conferida em cada fase e validada pelo build.

---

# Banco e comunicação

Cada microsserviço possui banco próprio. Nenhum serviço acessa o banco de outro; integrações são feitas por APIs ou eventos. Cada serviço terá seu próprio Docker Compose. SQL Server e RabbitMQ são infraestrutura compartilhada, fora dos serviços.

---

# CQRS e validação

Quando aplicável, usar MediatR para encaminhar Commands/Queries a handlers de Application e FluentValidation para validação. O fluxo não deve criar dependência de Application para Infrastructure.

---

# Segurança e multi-tenancy

Serviços que exigem autenticação validam JWT e aplicam roles/policies conforme seus casos de uso. Quando houver dados de tenant, o TenantId deve ser obtido de claims validadas e aplicado à autorização e à persistência; não confiar em identificadores enviados pelo cliente.

---

# Testes

Todo serviço deve possuir um projeto `NomeServico.Tests`. Cobrir casos de uso, regras de domínio e comportamento relevante de integração. A estrutura do projeto é criada na fase inicial; os pacotes de teste são definidos na fase de pacotes.

---

# Checklist

- Solution `.slnx` dentro de `Servicos/NomeServico`.
- Projetos API, Application, Domain, Infrastructure e Tests.
- Nenhuma referência de Application para Infrastructure.
- Build da solution validado.
- Pacotes, persistência, autenticação, Dockerfile e Compose adicionados nas fases correspondentes.
- Banco próprio e integração por API/eventos, sem compartilhamento de banco.
``