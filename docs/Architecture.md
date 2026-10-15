# Arquitetura

## Objetivo

Desenvolver uma plataforma SaaS multi-tenant baseada em microsserviços utilizando .NET (versão estável detectada automaticamente). A prioridade é aprender e validar a arquitetura, além de entregar funcionalidades.

O foco inicial é:

- Clean Architecture
- Autenticação com JWT
- Multi-tenancy
- Comunicação entre serviços por APIs ou eventos
- RabbitMQ
- Docker e Docker Swarm

---

# Stack Tecnológica

## Backend

- .NET (versão estável detectada automaticamente)
- ASP.NET Core
- Entity Framework Core
- MediatR para CQRS
- FluentValidation

## Banco de Dados

- SQL Server
- Um banco por microsserviço

## Mensageria e infraestrutura

- RabbitMQ
- Docker e Docker Swarm
- Docker Secrets para segredos
- Um arquivo Docker Compose por microsserviço; SQL Server e RabbitMQ são infraestrutura compartilhada e ficam fora deles.

## Segurança

- JWT
- Roles e policies conforme os casos de uso
- Chaves e credenciais fora do código-fonte

---

# Estrutura da Plataforma

Os serviços iniciais ficam em `Servicos`, cada um com sua própria solution e banco:

```text
Servicos
├── Authentication
├── Tenancy
└── Notification
```

---

# Microsserviços Iniciais

## Authentication

Responsável por:

- Login e emissão de JWT
- Refresh tokens
- Usuários e roles
- Primeiro acesso e troca obrigatória de senha
- Criação inicial da role e do usuário Admin por seed

Banco: `Db_Authentication`.

## Tenancy

Responsável pelo domínio de tenants e suas configurações. Banco: `Db_Tenancy`.

## Notification

Responsável por notificações e pelo processamento de eventos pertinentes ao serviço. Banco: `Db_Notification`.

---

# Comunicação

Os serviços não acessam diretamente os bancos uns dos outros. Quando um caso de uso precisar de integração, a comunicação ocorre por APIs ou eventos; RabbitMQ é a infraestrutura de mensageria compartilhada. Os fluxos e contratos específicos serão definidos ao implementar cada integração.

---

# Regras Arquiteturais

- Cada microsserviço possui seu próprio banco; nenhum serviço consulta ou altera o banco de outro.
- A integração entre serviços ocorre por APIs ou eventos, nunca por acesso direto ao banco alheio.
- Controllers não concentram regras de negócio.
- Application contém casos de uso e abstrações necessárias, e pode depender de Domain.
- Application não depende de Infrastructure.
- Infrastructure implementa as abstrações e integra recursos externos.
- Domain contém as regras de negócio e não conhece detalhes de infraestrutura.

---

# Evolução

As fases de Authentication são revisadas e validadas individualmente. A Fase 3 cria somente a estrutura da solution; as fases seguintes acrescentam pacotes, core, persistência, seed, JWT e fluxos de autenticação. A validação de cada fase inclui build e verificação da direção das dependências.