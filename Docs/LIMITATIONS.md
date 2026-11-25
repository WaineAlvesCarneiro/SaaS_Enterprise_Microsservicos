# Limitações atuais

Este documento registra o que ainda não está completo na automação atual.

## Seed não integrado ao startup

A Fase 8 gera `SeedData.cs` e executa build, mas a classe não é chamada automaticamente pelo `Program.cs` gerado na Fase 7. A criação do usuário administrador exige uma integração posterior ou uma execução explícita do seed.

## Migrations não aplicadas automaticamente

A Fase 6 gera a migration `InitialCreate`, mas não aplica automaticamente as migrations durante o startup da API.

## Refresh token

O `TokenService` gera um refresh token e sua data de expiração, mas:

- o token não é salvo em `RefreshTokens`;
- não existe endpoint de renovação;
- não existe fluxo HTTP de revogação;
- a resposta atual do login expõe apenas o access token.

## RabbitMQ

A infraestrutura RabbitMQ é criada e recebe um usuário administrador, mas a aplicação atual ainda não possui:

- publisher;
- consumer;
- exchanges da aplicação;
- filas da aplicação;
- eventos de integração implementados.

## Configuração da API

O `appsettings.json` é gerado com campos de servidor, host e usuário inicialmente vazios. A criação da infraestrutura não preenche automaticamente esses valores.

## Deploy

A Fase 3 gera Dockerfile e `docker-compose.yml`, porém os scripts atuais não:

- constroem a imagem da API;
- publicam a API no Docker Swarm;
- adicionam automaticamente os Docker Secrets ao serviço da API;
- configuram o deploy completo em produção.

## Testes

O projeto de testes e os pacotes são criados, mas os scripts não geram testes funcionais completos para:

- login;
- geração e validação de JWT;
- primeiro acesso;
- alteração de senha;
- seed;
- persistência.

## Segurança operacional

As credenciais iniciais do seed são conhecidas e destinadas ao ambiente inicial. Elas devem ser substituídas pelo usuário por meio do fluxo de alteração de senha e não devem ser utilizadas como credenciais permanentes de produção.

## Evolução planejada

As próximas etapas podem incluir:

- integração automática do seed e migrations;
- refresh token completo;
- revogação e logout;
- publicação de eventos RabbitMQ;
- testes automatizados;
- deploy da API no Swarm;
- microsserviços Tenancy e Notification.
