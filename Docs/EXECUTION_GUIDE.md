# Guia de execução

## Pré-requisitos

Disponibilize no `PATH`:

- PowerShell;
- Docker com suporte a Docker Swarm;
- .NET SDK;
- acesso ao NuGet.

O usuário precisa poder administrar Docker, Swarm, secrets, serviços, volumes e redes.

## Arquivos de secrets

Crie na raiz do repositório, antes da Fase 1:

```text
secrets_sql_sa_password.txt
secrets_rabbitmq_password.txt
secrets_jwt_key.txt
```

Não versione esses arquivos.

## Ordem recomendada

Execute a partir da raiz do repositório:

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
```

A Fase 0 é opcional e destrutiva. Use-a somente para remover os recursos de infraestrutura e reiniciar o ambiente.

## Responsabilidade de cada fase

| Fase | Responsabilidade |
|---|---|
| 0 | Remove serviços, volumes, secrets e rede configurados. |
| 1 | Inicializa o Swarm e cria Docker Secrets. |
| 2 | Cria a rede, SQL Server, RabbitMQ e usuário RabbitMQ. |
| 3 | Cria a solution, projetos, configurações e Dockerfile. |
| 4 | Instala/alinha pacotes NuGet e `dotnet-ef`. |
| 5 | Cria entidades, interfaces, modelos e validação do Core. |
| 6 | Cria persistência, configurações EF Core e migration. |
| 7 | Cria JWT, autorização, segurança e `Program.cs`. |
| 8 | Gera o código do seed inicial. |
| 9 | Gera login, repository, handler e endpoint. |
| 10 | Gera troca de senha e endpoint de primeiro acesso. |

## Reexecução

As fases podem ser reexecutadas, mas o comportamento varia:

- Fase 1 não recria secrets existentes;
- Fase 2 não recria serviços e rede existentes;
- Fase 3 evita recriar solution e projetos já existentes;
- Fases 5 e 6 validam arquivos existentes antes de criá-los;
- Fases 7, 8, 9 e 10 geram ou atualizam arquivos de código e executam build.

## Validações após a execução

Confirme:

1. os serviços Docker estão ativos;
2. os secrets existem;
3. a rede overlay foi criada;
4. a solution foi criada em `Servicos/Authentication`;
5. o arquivo `Authentication.TargetFramework.txt` existe na raiz do repositório;
6. a migration `InitialCreate` foi gerada;
7. o build da solution foi concluído;
8. a configuração de conexão e secrets da API foi ajustada para o ambiente.
