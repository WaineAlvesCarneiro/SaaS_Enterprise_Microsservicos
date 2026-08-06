# Diretrizes do Projeto: Microservices Enterprise SaaS (.NET)

## Regras Arquiteturais Obrigatórias
- Clean Architecture + DDD em todas as soluções.
- Proibido qualquer compartilhamento de banco de dados ou entidades entre microsserviços.
- Toda comunicação síncrona utiliza gRPC; comunicação assíncrona utiliza RabbitMQ via MassTransit.
- Todo endpoint ou handler deve aceitar CancellationToken.
- Rastreabilidade obriga propagação de CorrelationId e CausationId.
- Autenticação e Identity são centralizados exclusivamente no serviço Authentication.API.

## Convencionamento de Projetos
A estrutura de pastas do microsserviço X deve ser:
- Servico.X.API
- Servico.X.Application
- Servico.X.Domain
- Servico.X.Infrastructure
- Servico.X.Contracts
- Servico.X.Tests
