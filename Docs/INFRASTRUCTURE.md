# Infraestrutura

## Docker Swarm

A Fase 1 verifica o Docker e inicializa o Swarm quando ele está inativo. A Fase 2 exige que o Swarm esteja ativo antes de criar a infraestrutura.

## `.env.base`

As variáveis principais são:

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

A Fase 2 carrega o arquivo durante a execução. A Fase 0 também o lê para remover os mesmos nomes de serviços, volumes e rede.

## Docker Secrets

Secrets utilizados:

```text
sql_sa_password
rabbitmq_password
jwt_key
```

Os arquivos de origem são:

```text
secrets_sql_sa_password.txt
secrets_rabbitmq_password.txt
secrets_jwt_key.txt
```

## SQL Server

A Fase 2 cria um serviço SQL Server 2022 com:

- nome DNS e hostname configurados em `SQL_CONTAINER` (por padrão, `sqlserver2022`);
- o Docker Swarm acrescenta slot e ID aos nomes dos containers-task; esses nomes não podem ser definidos manualmente;
- rede configurada em `DOCKER_NETWORK`;
- secret `sql_sa_password`;
- volume configurado em `SQL_VOLUME`;
- porta publicada `1433:1433`;
- imagem `mcr.microsoft.com/mssql/server:2022-latest`.

## RabbitMQ

A Fase 2 cria um serviço RabbitMQ Management com:

- nome configurado em `RABBIT_CONTAINER`;
- rede configurada em `DOCKER_NETWORK`;
- secret `rabbitmq_password`;
- volume configurado em `RABBIT_VOLUME`;
- portas publicadas `5672:5672` e `15672:15672`;
- imagem `rabbitmq:3-management`.

Após aguardar o serviço responder, o script cria o usuário definido em `SPRING_RABBITMQ_USERNAME`, atribui a tag `administrator` e configura permissões no vhost `/`.

## Rede

A rede padrão é `infra_net`. O `docker-compose.yml` gerado para a API declara essa rede como externa.

## Limpeza

A Fase 0 remove os serviços, volumes, secrets e rede usando os nomes do `.env.base`. Na ausência do arquivo ou de alguma variável, utiliza os nomes padrão documentados no [README principal](../README.md).

## Observações

A criação da infraestrutura não publica automaticamente a API `Authentication` no Swarm. O Dockerfile e o `docker-compose.yml` são gerados na Fase 3, mas o deploy do microsserviço ainda é uma etapa separada.
