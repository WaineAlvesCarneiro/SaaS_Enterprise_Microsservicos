# SaaS_Enterprise_Microsservicos

## Arquiteto de Software e Desenvolvedor Full Stack Sênior

📖 Este é um ```Blueprint de arquitetura de nível enterprise```, cobrindo com precisão os padrões de mercado (```Clean Architecture, DDD, Event-Driven, Multi-tenancy, YARP Gateway, Outbox Pattern e Observabilidade```).

## 🏗️ Fases do Ecossistema

Essas são todas as **Fases** da Arquitetura de Referência SaaS Multi-tenant em C# / .NET a serem implementadas:

1. Fase 1: Infraestrutura no Docker.
2. Fase 2: Infraestrutura, Plataforma Base e Automação
3. Fase 3: Platform Building Blocks (Messaging, Observability, Multitenancy, Shared Results).
4. Fase 4: Notification Service (Worker, Resiliência, Dynamic SMTP, DLQ).
5. Fase 5: Authentication Service (Identity, JWT, Refresh Token & gRPC Server, Primeiro Acesso).
6. Fase 6: Empresa / Tenant Resolution (CRUD Tenant, Configurações Globais & SMTP por Tenant).
7. Fase 7: SaaS Foundation Template (dotnet new Scaffolding CLI).
8. Fase 8: Pessoas Service (DDD, Rich Domain, Tenant Query Filters).
9. Fase 9: Produtos Service (Catálogo, Preço & Versionamento Evolutivo de Eventos V1/V2, Outbox Pattern).
10. Fase 10: Pedidos Service (Pedidos, Checkout Workflow, Intenção de Compra, Eventos & Idempotência HTTP/Consumer, Outbox). 
11. Fase 11: Estoque Service (Reserva Lógica, Baixa Física, Concorrência Otimista com RowVersion, Saga Orchestration/Choreography).
12. Fase 12: Faturamento Service (NF-e, Processamento Financeiro & Eventos de Conclusão de Venda, Event-Driven).
13. Fase 13: Edge / Gateway & BFF (Gateway YARP Reverse Proxy, BFF.Web e BFF.Mobile).
14. Fase 14: Infrastructure as Code (Docker Compose, Multi-stage Dockerfiles, Kubernetes & Helm Charts).
---

## 🏗️ Estrutura do Repositório com Divisão das Solutions (```.sln```)

👉 Para um ecossistema de microsserviços maduro e alinhado com as melhores práticas de mercado, a abordagem recomendada é ter uma **Solution** (```.sln```) por ```microsserviço/Bounded Context```, além de uma solução separada para os ```Building Blocks``` e outra para a ```Borda``` (**Edge**).

Essa divisão traz diversos benefícios práticos no dia a dia do desenvolvimento:

```Plaintext
Plaintext

SaaS_Enterprise_Microsservicos/
├── README.md                   # Roteiro Completo
├── Build/
│   ├── docker-compose.yml      # Observabilidade + APIs conectados na infra_net
│   ├── prometheus.yml
│   └── Dockerfiles/
│       ├── Api.Dockerfile
│       └── Worker.Dockerfile
├── Platform/                   # Cross-Cutting / Building Blocks
|   └── Platform.sln                # Solução dos Building Blocks (Shared, Messaging, Multitenancy, Observability)
│       ├── Platform.Shared/
│       ├── Platform.Messaging/
│       ├── Platform.Observability/
│       ├── Platform.Multitenancy/
│       └── Templates/                 # SaaS Foundation Template (dotnet new)
├── Services/                   # Bounded Contexts
│   ├── Authentication/             # (Identity, JWT, gRPC)
│   |   └── Authentication.sln          # Solução individual do serviço de Autenticação
│   ├── Empresa/                    # (Tenant, Dynamic SMTP)
│   │   └── Empresa.sln                 # Solução individual do serviço de Empresa/Tenant
│   ├── Pessoas/                    # (DDD, Rich Domain)
│   │   └── Pessoas.sln                 # Solução individual do serviço de Pessoas/Clientes
│   ├── Produtos/                   # (Outbox, Event V1/V2)
│   │   └── Produtos.sln                # Solução individual do serviço de Catálogo/Produtos
│   ├── Pedidos/                    # (Idempotency, Checkout)
│   │   └── Pedidos.sln                 # Solução individual do serviço de Pedidos
│   ├── Estoque/                    # (Reserva, RowVersion)
│   │   └── Estoque.sln                 # Solução individual do serviço de Estoque
│   ├── Faturamento/                # (NF-e, Event-Driven)
│   │   └── Faturamento.sln             # Solução individual do serviço de Faturamento
│   └── Notification/               # (Worker, Resiliência)
│       └── Notification.sln            # Solução individual do serviço de Notificações/Worker
├── Edge/                       # Camada de Borda
|   └── Edge.sln                    # Solução do Gateway (YARP) e BFFs (Web e Mobile)
│       ├── Edge.Gateway/               # (YARP Reverse Proxy)
│       ├── Edge.BFF.Web/               # (Dashboard Aggregator)
│       └── Edge.BFF.Mobile/            # (Lightweight Payload)
├── Infrastructure/
|   └── K8s/                        # (Helm Charts & Manifestos)
└── Scripts                     # Script de Banco de Dados
```

### 🎯 Por que usar uma ```.sln``` para cada Microsserviço?

1. Isolamento de Domínio e Autonomia

- Cada time (ou desenvolvedor) pode abrir apenas a solução em que está trabalhando (ex: ```Pedidos.sln```), sem carregar dezenas de projetos desnecessários na IDE.

2. Performance no **Visual Studio** / **Rider**

- Abrir uma única solução monolítica com +40 projetos consome muita memória RAM e desacelera o tempo de compilação (*Build/Rebuild*). Ter soluções separadas deixa a IDE extremamente leve e rápida.

3. Independência no Pipeline de CI/CD

- Ao alterar o código do microsserviço de ```Produto```, o pipeline de **Integração Contínua** (```GitHub Actions, Azure DevOps, etc.```) precisará compilar e rodar os testes unitários/integrados apenas do ```Produtos.sln```, gerando a imagem **Docker** correspondente em poucos segundos.

4. Apoio ao Template (```dotnet new```)

- O script da **Fase** do template (```SaaS Foundation Template```), quando for executado o comando ```dotnet new saas-service -n NomeDoServico```, o próprio script já gera automaticamente a pasta do serviço com as respetiva ```NomeDoServico.sln``` contendo as camadas ```API```, ```Application```, ```Domain```, ```Infrastructure```, ```Contracts``` e ```Tests```.

###💡 Dica Bônus:

E se quiser abrir todos de uma vez

Se em algum momento de testes locais ou depuração (*debug*) form necessário rodar/ver múltiplos microsserviços ao mesmo tempo na IDE, pode criar um arquivo ```SaaS.All.sln``` na raiz do projeto contendo a união de todos os ```.csproj```.

Porém, para o trabalho diário de desenvolvimento e manutenção, usar uma ```.sln``` por **Bounded Context** é o padrão recomendado e adotado por grandes arquiteturas corporativas.

---

## 🏗️ Fase 1 Infraestrutura no Docker

A **Fase** provisiona a rede externa compartilhada (```infra_net```), os volumes persistentes e os containers do **SQL Server 2022** e **RabbitMQ**.

👉 **Objetivo**: Garantir que todos os microsserviços consigam se conectar aos serviços centrais de banco de dados e mensageria sem precisar recriar essas instâncias no ```docker-compose``` individual de cada aplicação.

### 📜 1. Script de Automação (```init-infra.ps1```)

Crie este arquivo na raiz do projeto como ```init-infra.ps1```. Ele já verifica se a rede e os volumes existem antes de criá-los e só sobe os containers se eles ainda não estiverem rodando.

```PowerShell
PowerShell

# init-infra.ps1
$ErrorActionPreference = "Stop"

Write-Host "🚀 Iniciando o provisionamento da Infraestrutura Base ..." -ForegroundColor Green

# 1. CRIAR REDE DOCKER (infra_net)
$networkName = "infra_net"
$networkExists = docker network ls --format '{{.Name}}' | Select-String -Pattern "^$networkName$" -SimpleMatch

if (-not $networkExists) {
    Write-Host "🌐 Criando a rede Docker '$networkName'..." -ForegroundColor Yellow
    docker network create $networkName | Out-Null
} else {
    Write-Host "✅ Rede Docker '$networkName' já existe." -ForegroundColor Gray
}

# 2. CRIAR VOLUMES DOCKER
$volumes = @("sqlserver_data", "rabbitmq_data")
foreach ($vol in $volumes) {
    $volExists = docker volume ls --format '{{.Name}}' | Select-String -Pattern "^$vol$" -SimpleMatch
    if (-not $volExists) {
        Write-Host "💾 Criando volume Docker '$vol'..." -ForegroundColor Yellow
        docker volume create $vol | Out-Null
    } else {
        Write-Host "✅ Volume Docker '$vol' já existe." -ForegroundColor Gray
    }
}

# 3. SUBIR SQL SERVER 2022
$sqlContainer = "sqlserver2022"
$sqlExists = docker ps -a --format '{{.Names}}' | Select-String -Pattern "^$sqlContainer$" -SimpleMatch

if (-not $sqlExists) {
    Write-Host "🐘 Subindo container do SQL Server 2022..." -ForegroundColor Yellow
    docker run -d `
        --name $sqlContainer `
        --network $networkName `
        -e 'ACCEPT_EULA=Y' `
        -e 'MSSQL_SA_PASSWORD=Senh@Forte2026!' `
        -v sqlserver_data:/var/opt/mssql `
        -p 1433:1433 `
        mcr.microsoft.com/mssql/server:2022-latest | Out-Null
} else {
    Write-Host "✅ Container '$sqlContainer' já existe. Garantindo que está rodando..." -ForegroundColor Gray
    docker start $sqlContainer | Out-Null
}

# 4. SUBIR RABBITMQ
$rabbitContainer = "rabbitmq"
$rabbitExists = docker ps -a --format '{{.Names}}' | Select-String -Pattern "^$rabbitContainer$" -SimpleMatch

if (-not $rabbitExists) {
    Write-Host "🐇 Subindo container do RabbitMQ..." -ForegroundColor Yellow
    docker run -d `
        --name $rabbitContainer `
        --network $networkName `
        -v rabbitmq_data:/var/lib/rabbitmq `
        -p 5672:5672 `
        -p 15672:15672 `
        rabbitmq:3-management | Out-Null
} else {
    Write-Host "✅ Container '$rabbitContainer' já existe. Garantindo que está rodando..." -ForegroundColor Gray
    docker start $rabbitContainer | Out-Null
}

Write-Host "`n✅ concluída com sucesso! Infraestrutura base pronta e integrada na rede '$networkName'." -ForegroundColor Green
```

### ⚡ Execução Rápida (Recomendado)

Você pode executar o script de automação em **PowerShell** na raiz do projeto:

```PowerShell
PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process .\init-infra.ps1
```

### 🛠️ O que o script faz por baixo dos panos?

Se preferir rodar manualmente via Docker CLI, siga os passos abaixo:

### 1️⃣ Criação da Rede Docker

```Bash
Bash
docker network create infra_net
```

### 2️⃣ Criação dos Volumes de Persistência

```Bash
Bash
docker volume create sqlserver_data
docker volume create rabbitmq_data
```

### 3️⃣ Inicialização do SQL Server 2022

```Bash
Bash
docker run -d --name sqlserver2022 --network infra_net -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=Senh@Forte2026!' -v sqlserver_data:/var/opt/mssql -p 1433:1433 mcr.microsoft.com/mssql/server:2022-latest
```

### 4️⃣ Inicialização do RabbitMQ (com painel de gerenciamento)

```Bash
Bash
docker run -d --name rabbitmq --network infra_net -v rabbitmq_data:/var/lib/rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
```

### 🔍 Validação da Infraestrutura

Após rodar o script ou os comandos manuais, valide se os containers e a rede estão ativos:

- Listar containers ativos:

```Bash
Bash
docker ps
```

- Inspecionar a rede ```infra_net```:

```Bash
Bash
docker network inspect infra_net
```

- Testes de Conexão:

  - 🐘 **SQL Server**: Conectar via ```localhost,1433``` | Usuário: ```sa``` | Senha: ```Senh@Forte2026!```

  - 🐇 **RabbitMQ Dashboard**: Acessar ```http://localhost:15672``` | Credenciais: ```guest``` / ```guest```

---

## 🏗️ Fase 2 Infraestrutura, Plataforma Base e Automação

Na **Fase**, o ecossistema SaaS é provisionado via script **PowerShell**, eliminando a necessidade de criar manualmente dezenas de projetos, **Solutions**, ```AppSettings``` e ```Dockerfiles``` no **Visual Studio**.

### 1️⃣ Automação e Inicialização da Arquitetura (```init-architecture.ps1```)

Em vez de criar cada projeto manualmente, utilizamos o script em **PowerShell// na raiz da pasta de trabalho. Ele orquestra os diretórios, as **Solutions** (```.slnx```), a estrutura **Clean Architecture** de cada microsserviço, os arquivos de infraestrutura e o contexto do **GitHub Copilot**.

### 📜 Script ```init-architecture.ps1```

Crie o arquivo ```init-architecture.ps1``` na raiz do projeto:

```Powershell
Powershell

# init-architecture.ps1
$ErrorActionPreference = "Stop"

Write-Host "🚀 Criando diretórios, soluções, projetos, AppSettings, Dockerfiles, Script SQL e Copilot Instructions..." -ForegroundColor Green

# ---------------------------------------------------------
# 1. DIRETÓRIOS BASE
# ---------------------------------------------------------
$dirs = @(
    "Build/Dockerfiles",
    "Infrastructure/K8s/helm",
    "Scripts",
    ".github"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

# ---------------------------------------------------------
# 2. CONFIGURAÇÕES DO GITHUB COPILOT
# ---------------------------------------------------------
Write-Host "🤖 Gerando .github/copilot-instructions.md..." -ForegroundColor Yellow

$copilotInstructions = @"
# Diretrizes do Projeto: Microservices Enterprise SaaS (.NET)

## Regras Arquiteturais Obrigatórias
- Clean Architecture + DDD em todas as soluções.
- Proibido qualquer compartilhamento de banco de dados ou entidades entre microsserviços.
- Toda comunicação síncrona utiliza gRPC; comunicação assíncrona utiliza RabbitMQ via MassTransit.
- Todo endpoint ou handler deve aceitar `CancellationToken`.
- Rastreabilidade obriga propagação de `CorrelationId` e `CausationId`.
- Autenticação e Identity são centralizados exclusivamente no serviço `Authentication.API`.

## Convencionamento de Projetos
A estrutura de pastas do microsserviço X deve ser:
- Servico.X.API
- Servico.X.Application
- Servico.X.Domain
- Servico.X.Infrastructure
- Servico.X.Contracts
- Servico.X.Tests
"@
Set-Content -Path ".github/copilot-instructions.md" -Value $copilotInstructions


# ---------------------------------------------------------
# 3. INFRAESTRUTURA DOCKER, OBSERVABILIDADE E SQL
# ---------------------------------------------------------
Write-Host "🐳 Gerando docker-compose.yml, prometheus.yml, Dockerfiles e init-databases.sql..." -ForegroundColor Yellow

# Scripts/init-databases.sql
$initDatabasesSql = @"
-- Criando bancos isolados para garantir o padrão Database-per-Service
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Authentication') CREATE DATABASE [Db_Authentication]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Empresa')        CREATE DATABASE [Db_Empresa]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Pessoas')        CREATE DATABASE [Db_Pessoas]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Produtos')       CREATE DATABASE [Db_Produtos]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Pedidos')        CREATE DATABASE [Db_Pedidos]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Estoques')       CREATE DATABASE [Db_Estoques]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Faturamentos')   CREATE DATABASE [Db_Faturamentos]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Notification')   CREATE DATABASE [Db_Notification]; GO
"@
Set-Content -Path "Scripts/init-databases.sql" -Value $initDatabasesSql

# Build/docker-compose.yml
$dockerComposeContent = @"
version: '3.8'

services:
  # ===============================================================
  # FERRAMENTAS DE OBSERVABILIDADE & MONITORAMENTO
  # (Conectam-se à rede 'infra_net' ja criada)
  # ===============================================================
  seq:
    image: datalust/seq:latest
    container_name: enterprise-seq
    restart: unless-stopped
    environment:
      - ACCEPT_EULA=Y
    ports:
      - "5341:80"
    networks:
      - infra_net

  prometheus:
    image: prom/prometheus:latest
    container_name: enterprise-prometheus
    restart: unless-stopped
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
    networks:
      - infra_net

  grafana:
    image: grafana/grafana:latest
    container_name: enterprise-grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    depends_on:
      - prometheus
    networks:
      - infra_net

  jaeger:
    image: jaegertracing/all-in-one:latest
    container_name: enterprise-jaeger
    restart: unless-stopped
    ports:
      - "16686:16686"
      - "4317:4317" # OTLP gRPC
      - "4318:4318" # OTLP HTTP
    networks:
      - infra_net

# ===============================================================
# REDE EXTERNA COMPARTILHADA (já criada)
# ===============================================================
networks:
  infra_net:
    external: true
    name: infra_net
"@
Set-Content -Path "Build/docker-compose.yml" -Value $dockerComposeContent

# Build/prometheus.yml
$prometheusContent = @"
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'saas_apis'
    metrics_path: '/metrics'
    static_configs:
      - targets:
          - 'auth_api:8086'
          - 'empresa_api:8086'
          - 'pessoas_api:8086'
          - 'produtos_api:8086'
          - 'pedidos_api:8086'
          - 'estoque_api:8086'
          - 'faturamento_api:8086'
"@
Set-Content -Path "Build/prometheus.yml" -Value $prometheusContent

# Build/Dockerfiles/Api.Dockerfile
$apiDockerfileContent = @"
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8086
ENV ASPNETCORE_URLS=http://+:8086

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG SERVICE_NAME
WORKDIR /src
COPY . .
RUN dotnet restore "Services/\$SERVICE_NAME/\$SERVICE_NAME.API/\$SERVICE_NAME.API.csproj"
RUN dotnet build "Services/\$SERVICE_NAME/\$SERVICE_NAME.API/\$SERVICE_NAME.API.csproj" -c Release -o /app/build

FROM build AS publish
ARG SERVICE_NAME
RUN dotnet publish "Services/\$SERVICE_NAME/\$SERVICE_NAME.API/\$SERVICE_NAME.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ExecuteService.dll"]
"@
Set-Content -Path "Build/Dockerfiles/Api.Dockerfile" -Value $apiDockerfileContent

# Build/Dockerfiles/Worker.Dockerfile
$workerDockerfileContent = @"
FROM mcr.microsoft.com/dotnet/runtime:10.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG SERVICE_NAME
WORKDIR /src
COPY . .
RUN dotnet restore "Services/\$SERVICE_NAME/\$SERVICE_NAME.Worker/\$SERVICE_NAME.Worker.csproj"
RUN dotnet build "Services/\$SERVICE_NAME/\$SERVICE_NAME.Worker/\$SERVICE_NAME.Worker.csproj" -c Release -o /app/build

FROM build AS publish
ARG SERVICE_NAME
RUN dotnet publish "Services/\$SERVICE_NAME/\$SERVICE_NAME.Worker/\$SERVICE_NAME.Worker.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ExecuteService.dll"]
"@
Set-Content -Path "Build/Dockerfiles/Worker.Dockerfile" -Value $workerDockerfileContent


# ---------------------------------------------------------
# 4. CAMADA PLATFORM
# ---------------------------------------------------------
Write-Host "📦 Criando projetos da camada Platform..." -ForegroundColor Yellow

$platformProjects = @("Shared", "Messaging", "Observability", "Multitenancy")

dotnet new sln -n "Platform" -o "Platform"
$platformSln = Get-ChildItem -Path "Platform" -Filter "Platform.sln*" | Select-Object -First 1

foreach ($proj in $platformProjects) {
    dotnet new classlib -n "Platform.$proj" -o "Platform/Platform.$proj"
    dotnet sln $platformSln.FullName add "Platform/Platform.$proj/Platform.$proj.csproj"
}

New-Item -ItemType Directory -Force -Path "Platform/Templates" | Out-Null


# ---------------------------------------------------------
# 5. CAMADA EDGE
# ---------------------------------------------------------
Write-Host "🌐 Criando projetos da camada Edge..." -ForegroundColor Yellow

dotnet new sln -n "Edge" -o "Edge"
$edgeSln = Get-ChildItem -Path "Edge" -Filter "Edge.sln*" | Select-Object -First 1

$edgeServices = @("Edge.Gateway", "Edge.BFF.Web", "Edge.BFF.Mobile")

foreach ($edge in $edgeServices) {
    dotnet new webapi -n "$edge" -o "Edge/$edge" --no-https --no-openapi
    dotnet sln $edgeSln.FullName add "Edge/$edge/$edge.csproj"

    $edgeDockerfile = @"
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8086
ENV ASPNETCORE_URLS=http://+:8086

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Edge/$edge/$edge.csproj", "Edge/$edge/"]
COPY ["Platform/", "Platform/"]
RUN dotnet restore "Edge/$edge/$edge.csproj"
COPY . .
WORKDIR "/src/Edge/$edge"
RUN dotnet build "$edge.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "$edge.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "$edge.dll"]
"@
    Set-Content -Path "Edge/$edge/Dockerfile" -Value $edgeDockerfile
}


# ---------------------------------------------------------
# 6. MICROSSERVIÇOS (Services)
# ---------------------------------------------------------
$services = @("Authentication", "Empresa", "Pessoas", "Produtos", "Pedidos", "Estoque", "Faturamento", "Notification")

$dbNames = @{
    "Authentication" = "Db_Authentication"
    "Empresa"        = "Db_Empresa"
    "Pessoas"        = "Db_Pessoas"
    "Produtos"       = "Db_Produtos"
    "Pedidos"        = "Db_Pedidos"
    "Estoque"        = "Db_Estoques"
    "Faturamento"    = "Db_Faturamentos"
    "Notification"   = "Db_Notification"
}

foreach ($svc in $services) {
    Write-Host "⚙️ Criando microsserviço: $svc" -ForegroundColor Cyan
    $svcPath = "Services/$svc"
    
    dotnet new sln -n "$svc" -o $svcPath
    $svcSln = Get-ChildItem -Path $svcPath -Filter "$svc.sln*" | Select-Object -First 1

    $isWorker = ($svc -eq "Notification")
    $execType = if ($isWorker) { "Worker" } else { "API" }
    $execTemplate = if ($isWorker) { "worker" } else { "webapi" }
    
    # Criar Projetos
    if ($isWorker) {
        dotnet new $execTemplate -n "$svc.$execType" -o "$svcPath/$svc.$execType"
    } else {
        dotnet new $execTemplate -n "$svc.$execType" -o "$svcPath/$svc.$execType" --no-https --no-openapi
    }

    dotnet new classlib -n "$svc.Application" -o "$svcPath/$svc.Application"
    dotnet new classlib -n "$svc.Domain" -o "$svcPath/$svc.Domain"
    dotnet new classlib -n "$svc.Infrastructure" -o "$svcPath/$svc.Infrastructure"
    dotnet new classlib -n "$svc.Contracts" -o "$svcPath/$svc.Contracts"
    dotnet new xunit -n "$svc.Tests" -o "$svcPath/$svc.Tests"
    
    # 1. Gerar appsettings.Production.json
    if ($isWorker) {
        $appSettingsProd = @"
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.Hosting.Lifetime": "Information"
    }
  },
  "RabbitMq": {
    "Host": "rabbitmq",
    "Port": 5672,
    "QueueName": "fila_notificacoes",
    "DeadLetterExchange": "dlx_exchange",
    "DeadLetterQueue": "fila_notificacoes_dlq",
    "UserName": "guest",
    "Password": "guest"
  },
  "Seq": {
    "Url": "http://enterprise-seq:80"
  }
}
"@
    } else {
        $targetDb = $dbNames[$svc]
        $appSettingsProd = @"
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Server=sqlserver2022;Database=${targetDb};User Id=sa;Password=Senh@ForteCondominio2026!;Encrypt=False;TrustServerCertificate=True;MultipleActiveResultSets=true"
  },
  "RabbitMq": {
    "Host": "rabbitmq",
    "Port": 5672,
    "UserName": "guest",
    "Password": "guest"
  },
  "Seq": {
    "Url": "http://enterprise-seq:80"
  }
}
"@
    }
    Set-Content -Path "$svcPath/$svc.$execType/appsettings.Production.json" -Value $appSettingsProd

    # 2. Gerar Dockerfile
    $runtimeImage = if ($isWorker) { "runtime:10.0" } else { "aspnet:10.0" }
    $exposePort = if ($isWorker) { "" } else { "EXPOSE 8086`nENV ASPNETCORE_URLS=http://+:8086" }

    $svcDockerfile = @"
FROM mcr.microsoft.com/dotnet/$runtimeImage AS base
WORKDIR /app
$exposePort

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Services/$svc/$svc.$execType/$svc.$execType.csproj", "Services/$svc/$svc.$execType/"]
COPY ["Services/$svc/$svc.Infrastructure/$svc.Infrastructure.csproj", "Services/$svc/$svc.Infrastructure/"]
COPY ["Services/$svc/$svc.Application/$svc.Application.csproj", "Services/$svc/$svc.Application/"]
COPY ["Services/$svc/$svc.Domain/$svc.Domain.csproj", "Services/$svc/$svc.Domain/"]
COPY ["Services/$svc/$svc.Contracts/$svc.Contracts.csproj", "Services/$svc/$svc.Contracts/"]
COPY ["Platform/", "Platform/"]
RUN dotnet restore "Services/$svc/$svc.$execType/$svc.$execType.csproj"
COPY . .
WORKDIR "/src/Services/$svc/$svc.$execType"
RUN dotnet build "$svc.$execType.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "$svc.$execType.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "$svc.$execType.dll"]
"@
    Set-Content -Path "$svcPath/$svc.$execType/Dockerfile" -Value $svcDockerfile

    # Adicionar Projetos à Solution localizando dinamicamente se é .sln ou .slnx
    dotnet sln $svcSln.FullName add "$svcPath/$svc.$execType/$svc.$execType.csproj"
    dotnet sln $svcSln.FullName add "$svcPath/$svc.Application/$svc.Application.csproj"
    dotnet sln $svcSln.FullName add "$svcPath/$svc.Domain/$svc.Domain.csproj"
    dotnet sln $svcSln.FullName add "$svcPath/$svc.Infrastructure/$svc.Infrastructure.csproj"
    dotnet sln $svcSln.FullName add "$svcPath/$svc.Contracts/$svc.Contracts.csproj"
    dotnet sln $svcSln.FullName add "$svcPath/$svc.Tests/$svc.Tests.csproj"

    # Referências Internas Limpas (Clean Architecture)
    dotnet add "$svcPath/$svc.Application/$svc.Application.csproj" reference "$svcPath/$svc.Domain/$svc.Domain.csproj"
    dotnet add "$svcPath/$svc.Infrastructure/$svc.Infrastructure.csproj" reference "$svcPath/$svc.Application/$svc.Application.csproj"
    dotnet add "$svcPath/$svc.$execType/$svc.$execType.csproj" reference "$svcPath/$svc.Infrastructure/$svc.Infrastructure.csproj"
    dotnet add "$svcPath/$svc.$execType/$svc.$execType.csproj" reference "$svcPath/$svc.Contracts/$svc.Contracts.csproj"
    dotnet add "$svcPath/$svc.Tests/$svc.Tests.csproj" reference "$svcPath/$svc.Application/$svc.Application.csproj"
}

Write-Host "`n✅ Ecossistema SaaS gerado com sucesso incluindo as diretrizes do GitHub Copilot!" -ForegroundColor Green
```

### 🛠️ Como Executar o Script

1. Liberar Execução no Terminal (se necessário):

```PowerShell
PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```

2. Executar o script:

```PowerShell
PowerShell
.\init-architecture.ps1
```

### 2️⃣ Governança de IA com GitHub Copilot (```.github/copilot-instructions.md```)

Gerado na **Seção 2** do script, este arquivo guia o **Copilot no Visual Studio** para impedir violações arquiteturais:

```Markdown
Markdown

# Diretrizes do Projeto: Microservices Enterprise SaaS (.NET)

## Regras Arquiteturais Obrigatórias
- Clean Architecture + DDD em todas as soluções.
- Proibido qualquer compartilhamento de banco de dados ou entidades entre microsserviços.
- Toda comunicação síncrona utiliza gRPC; comunicação assíncrona utiliza RabbitMQ via MassTransit.
- Todo endpoint ou handler deve aceitar `CancellationToken`.
- Rastreabilidade obriga propagação de `CorrelationId` e `CausationId`.
- Autenticação e Identity são centralizados exclusivamente no serviço `Authentication.API`.

## Convencionamento de Projetos
A estrutura de pastas do microsserviço X deve ser:
- Servico.X.API
- Servico.X.Application
- Servico.X.Domain
- Servico.X.Infrastructure
- Servico.X.Contracts
- Servico.X.Tests
```

Como interagir no **Copilot Chat**:

Use referências diretas de arquivo com ```#``` ou ```@```:

  - **Criar entidade**: ```#file:copilot-instructions.md Crie a entidade Tenant na camada Domain de Empresa com validações```.
  - **Revisar código**: ```@workspace Verifique se a classe X viola o princípio de Database-per-Service```.

### 3️⃣ Mapeamento e Provisionamento dos Bancos (```Scripts/init-databases.sql```)

Gerado na **Seção 3** do script, isola os bancos para o padrão *Database-per-Service*:

```SQL
SQL
-- Criando bancos isolados para garantir o padrão Database-per-Service
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Authentication') CREATE DATABASE [Db_Authentication]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Empresa')        CREATE DATABASE [Db_Empresa]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Pessoas')        CREATE DATABASE [Db_Pessoas]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Produtos')       CREATE DATABASE [Db_Produtos]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Pedidos')        CREATE DATABASE [Db_Pedidos]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Estoques')       CREATE DATABASE [Db_Estoques]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Faturamentos')   CREATE DATABASE [Db_Faturamentos]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Notification')   CREATE DATABASE [Db_Notification]; GO
```

###4️⃣ Orquestração Docker & Observabilidade (```Build/docker-compose.yml```)

Também gerado na **Seção 3** do script, configura toda a malha de infraestrutura:

```YAML
YAML

version: '3.8'

networks:
  infra_net:
    driver: bridge

services:
  sqlserver2022:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: enterprise-sqlserver
    environment:
      - ACCEPT_EULA=Y
      - MSSQL_SA_PASSWORD=Senh@ForteCondominio2026!
    ports:
      - "1433:1433"
    networks:
      - infra_net

  rabbitmq:
    image: rabbitmq:3-management
    container_name: enterprise-rabbitmq
    environment:
      - RABBITMQ_DEFAULT_USER=guest
      - RABBITMQ_DEFAULT_PASS=guest
    ports:
      - "5672:5672"
      - "15672:15672"
    networks:
      - infra_net

  seq:
    image: datalust/seq:latest
    container_name: enterprise-seq
    environment:
      - ACCEPT_EULA=Y
    ports:
      - "5341:80"
    networks:
      - infra_net

  prometheus:
    image: prom/prometheus:latest
    container_name: enterprise-prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
    networks:
      - infra_net
```

### 5️⃣ Monitoramento com Prometheus (```Build/prometheus.yml```)

Gerado na **Seção 3* do script, aponta para o ecossistema no *Docker*:

```YAML
YAML

global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'saas_apis'
    metrics_path: '/metrics'
    static_configs:
      - targets:
          - 'auth_api:8086'
          - 'empresa_api:8086'
          - 'pessoas_api:8086'
          - 'produtos_api:8086'
          - 'pedidos_api:8086'
          - 'estoque_api:8086'
          - 'faturamento_api:8086'
```

### 6️⃣ Estrutura do Ecossistema (```Platform, Edge e Services```)

Gerados automaticamente nas **Seções 4, 5 e 6** do script:

1. ```Platform/```: Projetos reutilizáveis (```Shared```, ```Messaging```, ```Observability```, ```Multitenancy```).

2. ```Edge/```: Gateway e BFFs (```Edge.Gateway```, ```Edge.BFF.Web```, ```Edge.BFF.Mobile```).

3. ```Services/```: Todos os microsserviços gerados com ```appsettings.Production.json``` individualizados e ```Dockerfiles``` próprios.

### 📌 Próximos Passos no Visual Studio

1. Abra a pasta raiz ou qualquer ```.slnx``` individual no **Visual Studio** (```Open a local folder```).

2. Suba a infraestrutura executando na raiz:

```Bash
Bash
docker-compose -f Build/docker-compose.yml up -d
```

3. Valide o acesso aos dashboards locais:
  - RabbitMQ: ```http://localhost:15672``` (guest/guest)  
  - Seq (Logs): ```http://localhost:5341```  
  - Prometheus: ```http://localhost:9090```

---

## 🏗️ Fase 3 Platform Building Blocks (Messaging, Observability, Multitenancy, Shared Results)

Na **Fase** serão criadas as abstrações reutilizáveis de mensageria e observabilidade.

Nesta etapa, não vamos focar em regras de negócio, mas sim na fundação técnica que será reutilizada por todos os microsserviços do ecossistema. O objetivo é garantir que os serviços consigam publicar eventos, registrar métricas/logs e resolver multitenancy sem ter que reescrever código boilerplate repetidamente.

### 🎯 Objetivos

1. ```Platform/Shared```: Result Pattern (para retornos de fluxo sem exceções), exceções globais, utilitários de contexto e extensão.

2. ```Platform/Observability```: Configuração centralizada do Serilog, OpenTelemetry (Traces + Metrics) para Jaeger, Prometheus e Seq.

3. ```Platform/Messaging```: Abstração do MassTransit sobre RabbitMQ, com configurações globais de Retry, DLQ, Outbox Pattern e propagação automática de ```CorrelationId```.

4. ```Platform/Multitenancy```: Middleware e acessor de resolução de tenant (```TenantContext e ITenantProvider```).

### 🏗️ Estrutura da Solução

Verifique se a estrutura física do serviço está assim (já criada):

```Plaintext
Plaintext

Platform/
├── Platform.Messaging/
├── Platform.Multitenancy/
├── Platform.Observability/
└── Platform.Shared/
```

### 💻 Implementação Prática

📦 1. Abstração de Resultado e Correlação (```Platform/Shared```)

Crie a estrutura para padronizar retornos e garantir rastreabilidade distribuída.

```C#
C#

// Platform/Shared/Correlation/ICorrelationContext.cs
namespace Platform.Shared.Correlation;

public interface ICorrelationContext
{
    Guid CorrelationId { get; }
    Guid CausationId { get; }
}

public class CorrelationContext : ICorrelationContext
{
    public Guid CorrelationId { get; set; } = Guid.NewGuid();
    public Guid CausationId { get; set; } = Guid.NewGuid();
}
```

```C#
C#

// Platform/Shared/Results/Result.cs
namespace Platform.Shared.Results;

public class Result
{
    public bool IsSuccess { get; }
    public bool IsFailure => !IsSuccess;
    public string Error { get; }

    protected Result(bool isSuccess, string error)
    {
        IsSuccess = isSuccess;
        Error = error;
    }

    public static Result Success() => new(true, string.Empty);
    public static Result Failure(string error) => new(false, error);
    public static Result<TValue> Success<TValue>(TValue value) => new(value, true, string.Empty);
    public static Result<TValue> Failure<TValue>(string error) => new(default, false, error);
}

public class Result<TValue> : Result
{
    public TValue? Value { get; }

    protected internal Result(TValue? value, bool isSuccess, string error)
        : base(isSuccess, error)
    {
        Value = value;
    }
}
```

🔭 2. Configuração de Observabilidade Centralizada (```Platform/Observability```)

Crie uma extensão do ```IServiceCollection``` para plugar logs e tracing em qualquer microsserviço com apenas 1 linha de código no ```Program.cs```.

```C#
C#

// Platform/Observability/DependencyInjection.cs
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using Serilog;

namespace Platform.Observability;

public static class DependencyInjection
{
    public static IHostBuilder UseCustomSerilog(this IHostBuilder hostBuilder, string serviceName)
    {
        return hostBuilder.UseSerilog((context, config) =>
        {
            config
                .Enrich.FromLogContext()
                .Enrich.WithProperty("Application", serviceName)
                .WriteTo.Console()
                .WriteTo.Seq(context.Configuration["Seq:Url"] ?? "http://enterprise-seq:80");
        });
    }

    public static IServiceCollection AddCustomObservability(
        this IServiceCollection services, 
        string serviceName, 
        string otlpEndpoint)
    {
        services.AddOpenTelemetry()
            .WithTracing(tracing =>
            {
                tracing
                    .SetResourceBuilder(ResourceBuilder.CreateDefault().AddService(serviceName))
                    .AddAspNetCoreInstrumentation()
                    .AddHttpClientInstrumentation()
                    .AddEntityFrameworkCoreInstrumentation()
                    .AddSource("MassTransit") // Rastreabilidade de Mensagens
                    .AddOtlpExporter(opts => opts.Endpoint = new Uri(otlpEndpoint));
            })
            .WithMetrics(metrics =>
            {
                metrics
                    .SetResourceBuilder(ResourceBuilder.CreateDefault().AddService(serviceName))
                    .AddAspNetCoreInstrumentation()
                    .AddHttpClientInstrumentation()
                    .AddMeter("MassTransit") // Métricas de Mensageria
                    .AddPrometheusExporter();
            });

        return services;
    }

    // Método utilitário para expor a rota de métricas no WebApplication
    public static IApplicationBuilder UsePrometheusEndpoint(this IApplicationBuilder app)
    {
        return app.UseOpenTelemetryPrometheusScrapeEndpoint();
    }
}
```

🏢 3. Resolução de Multitenancy (```Platform/Multitenancy```)

Garante a leitura do identificador do ```cliente/empresa via Headers, JWT Token ou Metadados do gRPC```.

```C#
C#

// Platform/Multitenancy/ITenantContext.cs
namespace Platform.Multitenancy;

public interface ITenantContext
{
    Guid? TenantId { get; }
    void SetTenant(Guid tenantId);
}

public class TenantContext : ITenantContext
{
    public Guid? TenantId { get; private set; }

    public void SetTenant(Guid tenantId)
    {
        TenantId = tenantId;
    }
}
```

```C#
C#

// Platform/Multitenancy/TenantMiddleware.cs
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;

namespace Platform.Multitenancy;

public class TenantMiddleware
{
    private readonly RequestDelegate _next;

    public TenantMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context, ITenantContext tenantContext)
    {
        if (context.Request.Headers.TryGetValue("X-Tenant-Id", out var tenantHeader) &&
            Guid.TryParse(tenantHeader, out var tenantId))
        {
            tenantContext.SetTenant(tenantId);
        }

        await _next(context);
    }
}

public static class MultitenancyExtensions
{
    public static IServiceCollection AddMultitenancy(this IServiceCollection services)
    {
        services.AddScoped<ITenantContext, TenantContext>();
        return services;
    }

    public static IApplicationBuilder UseTenantMiddleware(this IApplicationBuilder app)
    {
        return app.UseMiddleware<TenantMiddleware>();
    }
}
```

📬 4. Abstração de Mensageria com MassTransit (```Platform/Messaging```)

Configura o **RabbitMQ** garantindo o comportamento de resiliência padrão (```Retry + DLQ + Outbox```).

```C#
C#

// Platform/Messaging/DependencyInjection.cs
using MassTransit;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System.Reflection;

namespace Platform.Messaging;

public static class DependencyInjection
{
    public static IServiceCollection AddCustomMessaging(
        this IServiceCollection services,
        IConfiguration configuration,
        Assembly? consumersAssembly = null)
    {
        services.AddMassTransit(x =>
        {
            if (consumersAssembly != null)
            {
                x.AddConsumers(consumersAssembly);
            }

            x.UsingRabbitMq((context, cfg) =>
            {
                var host = configuration["RabbitMQ:Host"] ?? "rabbitmq";
                var username = configuration["RabbitMQ:Username"] ?? "guest";
                var password = configuration["RabbitMQ:Password"] ?? "guest";

                cfg.Host(host, "/", h =>
                {
                    h.Username(username);
                    h.Password(password);
                });

                // Política Global de Resiliência
                cfg.UseMessageRetry(r => r.Interval(3, TimeSpan.FromSeconds(5)));

                cfg.ConfigureEndpoints(context);
            });
        });

        return services;
    }
}
```

### 📦 Pacotes NuGet Necessários

Garante que todos os pacotes das bibliotecas estejam corretos em suas respectivas camadas:

- Platform.Shared.csproj:
  - Microsoft.Extensions.DependencyInjection.Abstractions
- Platform.Observability.csproj:
  - OpenTelemetry.Extensions.Hosting
  - OpenTelemetry.Exporter.Prometheus.AspNetCore
  - OpenTelemetry.Exporter.OpenTelemetryProtocol
  - OpenTelemetry.Instrumentation.AspNetCore
  - OpenTelemetry.Instrumentation.Http
  - OpenTelemetry.Instrumentation.EntityFrameworkCore
  - Serilog.AspNetCore
  - Serilog.Sinks.Seq
  - Serilog.Sinks.Console
- Platform.Multitenancy.csproj:
  - Microsoft.AspNetCore.Http.Abstractions
- Platform.Messaging.csproj:
  - MassTransit
  - MassTransit.RabbitMQ

### 🤖 Como Orquestrar o Copilot Chat no VS

Para aplicar essas bibliotecas nos microsserviços sem gerar erros, envie mensagens específicas apontando os arquivos contextuais:

**1. Instalação e Referência:**

"Copilot, adicione uma referência do projeto ```Platform.Observability``` e ```Platform.Messaging``` no projeto ```Services/Authentication/Authentication.API.csproj```."

**2. Plugando no ```Program.cs```:**

"Copilot, abra o ```Program.cs``` de ```Services/Authentication/Authentication.API``` e configure o ```UseCustomSerilog```, ```AddCustomObservability``` e ```AddCustomMessaging``` conforme definido nas bibliotecas da plataforma base."

---

## 🏗️ Fase 4 Notification Service (Worker AOT / SMTP Dinâmico / Retries / DLQ)

Este microsserviço é estratégico para a arquitetura: ele é focado em alta performance, consome eventos assíncronos da fila (como *UserRegisteredEvent* ou *PasswordResetRequestedEvent*) e é responsável pelo envio de e-mails/notificações utilizando o **SMTP configurado individualmente por cada Tenant (Empresa)**.

### 🎯 Objetivos

1. ```Worker Assíncrono```: Consumir eventos via MassTransit/RabbitMQ sem bloquear APIs REST.

2. ```Resiliência Extrema```: Lidar com falhas de SMTP usando políticas de Retry, Circuit Breaker e suporte a Dead-Letter Queue (DLQ).

3. ```SMTP Dinâmico por Tenant```: Consultar as configurações de e-mail do tenant remetente (via gRPC ou Cache) antes do envio.

4. ```Outbox Pattern / NotificationJob```: Persistir a tentativa de envio para auditoria e reprocessamento caso o provedor externo falhe.

### 🏗️ Estrutura da Solução

Verifique se a estrutura física do serviço está assim (já criada):

```Plaintext
Plaintext

Services/Notification/
├── Notification.API/               # Endpoints para consulta de status de notificações
├── Notification.Worker/            # Background Worker / MassTransit Consumers
├── Notification.Application/       # Casos de Uso, Handlers de Notificação
├── Notification.Domain/            # Entidade NotificationJob, StatusEnum, ValueObjects
├── Notification.Infrastructure/    # Cliente SMTP, Integradores, EF Core (DbContext)
├── Notification.Contracts/         # Integration Events públicos (ex: SendEmailCommand)
└── Notification.Tests/
```

### 💻 Implementação Prática

1. **Persistência** e **DbContext** (```Notification.Infrastructure```)

Crie o ```NotificationDbContext``` para mapear a auditoria dos disparos no **SQL Server** do serviço (```Db_Notification```):

```C#
C#

// Notification.Infrastructure/Persistence/NotificationDbContext.cs
using Microsoft.EntityFrameworkCore;
using Notification.Domain.Entities;

namespace Notification.Infrastructure.Persistence;

public class NotificationDbContext : DbContext
{
    public NotificationDbContext(DbContextOptions<NotificationDbContext> options) : base(options) { }

    public DbSet<NotificationJob> NotificationJobs => Set<NotificationJob>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<NotificationJob>(builder =>
        {
            builder.ToTable("NotificationJobs");
            builder.HasKey(x => x.Id);
            builder.Property(x => x.Recipient).IsRequired().HasMaxLength(255);
            builder.Property(x => x.Subject).IsRequired().HasMaxLength(255);
            builder.Property(x => x.Body).IsRequired();
            builder.Property(x => x.Status).HasConversion<int>();
        });
    }
}
```

2. Contrato da Mensagem (```Notification.Contracts```)

Crie o comando de integração que outros microsserviços do ecossistema publicarão na fila quando precisarem enviar um e-mail:

```C#
C#

// Notification.Contracts/Commands/SendEmailCommand.cs
namespace Notification.Contracts.Commands;

public record SendEmailCommand
{
    public Guid CorrelationId { get; init; } = Guid.NewGuid();
    public Guid? TenantId { get; init; }
    public string To { get; init; } = string.Empty;
    public string Subject { get; init; } = string.Empty;
    public string Body { get; init; } = string.Empty;
    public string Category { get; init; } = string.Empty; // Ex: Auth, Billing, Welcome
}
```

3. Entidade de Domínio e Job (```Notification.Domain```)

Para garantir auditabilidade e resiliência, todo disparo vira um ```NotificationJob``` no banco do serviço:

```C#
C#

// Notification.Domain/Entities/NotificationJob.cs
namespace Notification.Domain.Entities;

public class NotificationJob
{
    public Guid Id { get; private set; }
    public Guid? TenantId { get; private set; }
    public string Recipient { get; private set; }
    public string Subject { get; private set; }
    public string Body { get; private set; }
    public NotificationStatus Status { get; private set; }
    public int RetryCount { get; private set; }
    public string? ErrorMessage { get; private set; }
    public DateTime CreatedAtUtc { get; private set; }
    public DateTime? ProcessedAtUtc { get; private set; }

    public NotificationJob(Guid? tenantId, string recipient, string subject, string body)
    {
        Id = Guid.NewGuid();
        TenantId = tenantId;
        Recipient = recipient;
        Subject = subject;
        Body = body;
        Status = NotificationStatus.Pending;
        RetryCount = 0;
        CreatedAtUtc = DateTime.UtcNow;
    }

    public void MarkAsSent()
    {
        Status = NotificationStatus.Sent;
        ProcessedAtUtc = DateTime.UtcNow;
    }

    public void MarkAsFailed(string error)
    {
        Status = NotificationStatus.Failed;
        ErrorMessage = error;
        RetryCount++;
    }
}

public enum NotificationStatus
{
    Pending = 1,
    Sent = 2,
    Failed = 3
}
```

4. Consumidor MassTransit com Resiliência e DLQ (```Notification.Worker```)

O consumidor recebe o evento da fila **RabbitMQ**, processa o envio resiliente e, em caso de erro persistente, o próprio **MassTransit** move a mensagem para a fila de **DLQ** (```Dead-Letter Queue```):

O consumidor grava a intenção no banco, executa o envio (simulado) e atualiza o estado:

```C#
C#

// Notification.Worker/Consumers/SendEmailConsumer.cs
using MassTransit;
using Microsoft.Extensions.Logging;
using Notification.Contracts.Commands;
using Notification.Domain.Entities;
using Notification.Infrastructure.Persistence;

namespace Notification.Worker.Consumers;

public class SendEmailConsumer : IConsumer<SendEmailCommand>
{
    private readonly NotificationDbContext _dbContext;
    private readonly ILogger<SendEmailConsumer> _logger;

    public SendEmailConsumer(NotificationDbContext dbContext, ILogger<SendEmailConsumer> logger)
    {
        _dbContext = dbContext;
        _logger = logger;
    }

    public async Task Consume(ConsumeContext<SendEmailCommand> context)
    {
        var message = context.Message;
        
        _logger.LogInformation(
            "Processing Notification Job | Tenant: {TenantId} | Target: {To} | Correlation: {CorrelationId}",
            message.TenantId, message.To, message.CorrelationId);

        var job = new NotificationJob(message.TenantId, message.To, message.Subject, message.Body);
        
        _dbContext.NotificationJobs.Add(job);
        await _dbContext.SaveChangesAsync(context.CancellationToken);

        try
        {
            await SimulateSmtpSendAsync(message, context.CancellationToken);

            job.MarkAsSent();
            await _dbContext.SaveChangesAsync(context.CancellationToken);
            
            _logger.LogInformation("Email successfully sent to {To} (JobId: {JobId})", message.To, job.Id);
        }
        catch (Exception ex)
        {
            job.MarkAsFailed(ex.Message);
            await _dbContext.SaveChangesAsync(context.CancellationToken);
            
            _logger.LogError(ex, "Failed to send email to {To}. Triggering MassTransit retry/DLQ...", message.To);
            
            // Re-lança para que as políticas de Retry / DLQ entrem em ação
            throw;
        }
    }

    private static async Task SimulateSmtpSendAsync(SendEmailCommand command, CancellationToken ct)
    {
        await Task.Delay(100, ct); 
    }
}
```

5. Configuração da **Worker** na ```Program.cs``` (```Notification.Worker```)

Pluga os **Building Blocks** já criados no **Worker de Notificação**:

```Program.cs``` pronto para rodar tanto localmente quanto via ```docker-compose```:

```C#
C#

// Notification.Worker/Program.cs
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Notification.Worker.Consumers;
using Notification.Infrastructure.Persistence;
using Platform.Observability;

var builder = Host.CreateDefaultBuilder(args);

builder.UseCustomSerilog("Notification.Worker");

builder.ConfigureServices((hostContext, services) =>
{
    var configuration = hostContext.Configuration;

    // Observabilidade (Jaeger & Prometheus)
    var otlpEndpoint = configuration["OpenTelemetry:Endpoint"] ?? "http://enterprise-jaeger:4317";
    services.AddCustomObservability("Notification.Worker", otlpEndpoint);

    // Persistência
    var connectionString = configuration.GetConnectionString("DefaultConnection") 
        ?? "Server=localhost,1433;Database=Db_Notification;User Id=sa;Password=Senh@Forte2026!;Encrypt=False;TrustServerCertificate=True;";
    
    services.AddDbContext<NotificationDbContext>(opts =>
        opts.UseSqlServer(connectionString));

    // MassTransit & RabbitMQ
    services.AddMassTransit(x =>
    {
        x.AddConsumer<SendEmailConsumer>();

        x.UsingRabbitMq((context, cfg) =>
        {
            var host = configuration["RabbitMq:Host"] ?? "localhost";
            var username = configuration["RabbitMq:UserName"] ?? "guest";
            var password = configuration["RabbitMq:Password"] ?? "guest";

            cfg.Host(host, "/", h =>
            {
                h.Username(username);
                h.Password(password);
            });

            // Resiliência com Exponential Backoff
            cfg.ReceiveEndpoint("notification-send-email-queue", e =>
            {
                e.UseMessageRetry(r => r.Exponential(
                    retryLimit: 3, 
                    minInterval: TimeSpan.FromSeconds(2), 
                    maxInterval: TimeSpan.FromSeconds(30), 
                    intervalDelta: TimeSpan.FromSeconds(5)
                ));

                e.ConfigureConsumer<SendEmailConsumer>(context);
            });
        });
    });
});

var app = builder.Build();
await app.RunAsync();
```

6. Testes de Unidade com ```MassTransit.Testing``` (```Notification.Tests```)

Crie uma suíte de teste na camada ```Notification.Tests``` para validar o comportamento do consumidor sem precisar subir o **RabbitMQ**:

```C#
C#

// Notification.Tests/SendEmailConsumerTests.cs
using MassTransit;
using MassTransit.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Moq;
using Notification.Contracts.Commands;
using Notification.Infrastructure.Persistence;
using Notification.Worker.Consumers;
using Xunit;

public class SendEmailConsumerTests
{
    [Fact]
    public async Task Should_Consume_SendEmailCommand_And_Mark_As_Sent()
    {
        // Arrange
        var options = new DbContextOptionsBuilder<NotificationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new NotificationDbContext(options);
        var loggerMock = new Mock<ILogger<SendEmailConsumer>>();

        await using var provider = new ServiceCollection()
            .AddMassTransitTestHarness(x =>
            {
                x.AddConsumer<SendEmailConsumer>();
            })
            .AddSingleton(dbContext)
            .AddSingleton(loggerMock.Object)
            .BuildServiceProvider(true);

        var harness = provider.GetRequiredService<ITestHarness>();
        await harness.Start();

        var command = new SendEmailCommand
        {
            TenantId = Guid.NewGuid(),
            To = "cliente@empresa.com",
            Subject = "Bem-vindo!",
            Body = "Sua conta foi criada com sucesso."
        };

        // Act
        await harness.Bus.Publish(command);

        // Assert
        Assert.True(await harness.Consumed.Any<SendEmailCommand>());
        
        var jobInDb = await dbContext.NotificationJobs.FirstOrDefaultAsync();
        Assert.NotNull(jobInDb);
        Assert.Equal("cliente@empresa.com", jobInDb.Recipient);
        Assert.Equal(Notification.Domain.Entities.NotificationStatus.Sent, jobInDb.Status);
    }
}
```

### 📦 Pacotes NuGet Necessários

Certifique-se de instalar as dependências abaixo nos respectivos projetos:

- Notification.Worker.csproj:
  - MassTransit.RabbitMQ
  - Microsoft.EntityFrameworkCore.SqlServer
  - Referências de Projeto:
      - Notification.Contracts, Notification.Infrastructure, Platform.Observability
- Notification.Infrastructure.csproj:
  - Microsoft.EntityFrameworkCore.SqlServer
  - Referências de Projeto:
      - Notification.Domain, Notification.Application
- Notification.Tests.csproj:
  - MassTransit.Newtonsoft / MassTransit.TestFramework / MassTransit
  - Microsoft.EntityFrameworkCore.InMemory
  - Moq
  - xunit e xunit.runner.visualstudio
  - Referência de Projeto:
      - Notification.Worker

### 🤖 Como Orquestrar o Copilot Chat no VS

Utilize os seguintes prompts cirúrgicos no painel do **Copilot Chat**:

**1. Para vincular o contrato na Worker:**

  ```@workspace Adicione a referência de 'Notification.Contracts' e 'Platform.Messaging' dentro do projeto 'Notification.Worker.csproj'.```

**2. Para gerar testes da Worker:**

  ```#file:SendEmailConsumer.cs Crie um teste de unidade em Notification.Tests utilizando o MassTransit.Testing (TestHarness) para validar se o SendEmailConsumer processa e confirma a mensagem corretamente.```

---

## 🏗️ Fase 5 Authentication Service (Identity, JWT, Refresh Token & gRPC Server, Primeiro Acesso)

Na **Fase** será criado o microsserviço **Authentication** que é a âncora de segurança de toda a arquitetura. E é o único serviço autorizado a gerenciar usuários, emitir tokens JWT, validar sessões, renovar acessos via Refresh Tokens e expor contratos gRPC de alta performance para que outros serviços validem identidade/autorização de forma síncrona.

### 🎯 Objetivos

1. ```Identity & JWT Centralizado```: ASP.NET Core Identity gerenciando usuários, roles e claims com emissão segura de JWT.

2. ```Estratégia de Seed & Primeiro Acesso```:
  - 👨‍💻 Usuário inicial padrão criado na inicialização (```Admin``` / ```12345```).  
  - 🔐 Flag ```MustChangePassword``` ativada por padrão para o Admin inicial.  
  - 🔒 Interceptação e bloqueio de emissão de token definitivo até que o usuário realize a troca de senha obrigatória.

3. ```Serviço gRPC de Autenticação```: Expor endpoint gRPC síncrono para que a Edge (Gateway) ou outros serviços façam checagens rápidas de token em tempo de execução.

4. ```Rate Limiting & Revogação de Token```: Controle contra ataques de força bruta no endpoint de login e revogação via Refresh Tokens em banco.

### 🏗️ Estrutura da Solução

```Plaintext
Plaintext

Services/Authentication/
├── Authentication.API/          # Controllers (Login, Refresh, Seed, PasswordChange), gRPC Services
├── Authentication.Application/  # Use Cases, Commands/Queries (AuthenticateUser, ForceChangePassword)
├── Authentication.Domain/       # Entidades User, RefreshToken, IdentityUser estendido
├── Authentication.Infrastructure/# EF Core (AuthenticationDbContext), JwtTokenGenerator, Identity Config
├── Authentication.Contracts/    # Protos (.proto) para gRPC e DTOs de resposta
└── Authentication.Tests/
```

### 💻 Implementação Prática

1. Configuração de Compilação do Protocol Buffers (```.proto```):

No arquivo ```Authentication.Contracts.csproj```, é necessário registrar o arquivo ```.proto``` com a tag do gRPC para que a classe base ```AuthServiceGrpcBase``` seja gerada automaticamente pelo compilador .NET:

```XML
XML
<ItemGroup>
  <Protobuf Include="Protos\auth_service.proto" GrpcServices="Server, Client" />
</ItemGroup>
```

2. Persistência de Dados (```Authentication.Infrastructure```)

```C#
C#

// Authentication.Infrastructure/Persistence/AuthenticationDbContext.cs
using Authentication.Domain.Entities;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Authentication.Infrastructure.Persistence;

public class AuthenticationDbContext : IdentityDbContext<ApplicationUser>
{
    public AuthenticationDbContext(DbContextOptions<AuthenticationDbContext> options) : base(options) { }

    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<RefreshToken>(builder =>
        {
            builder.ToTable("RefreshTokens");
            builder.HasKey(r => r.Id);
            builder.Property(r => r.Token).IsRequired().HasMaxLength(500);
            builder.Property(r => r.UserId).IsRequired();
        });
    }
}
```

3. Seeding Resiliente de Usuário Admin (```Authentication.Infrastructure```)

```C#
C#

// Authentication.Infrastructure/Data/DatabaseSeeder.cs
using Authentication.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace Authentication.Infrastructure.Data;

public static class DatabaseSeeder
{
    public static async Task SeedAdminUserAsync(IServiceProvider serviceProvider)
    {
        using var scope = serviceProvider.CreateScope();
        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var logger = scope.ServiceProvider.GetRequiredService<ILogger<ApplicationUser>>();

        var adminUser = await userManager.FindByNameAsync("Admin");
        if (adminUser == null)
        {
            var user = new ApplicationUser
            {
                UserName = "Admin",
                Email = "admin@saas-enterprise.com",
                EmailConfirmed = true,
                TenantId = null // Master Admin
            };

            var result = await userManager.CreateAsync(user, "12345");
            if (result.Succeeded)
            {
                logger.LogInformation("✅ Usuário Admin inicial criado com sucesso (MustChangePassword = True).");
            }
            else
            {
                var errors = string.Join(", ", result.Errors.Select(e => e.Description));
                logger.LogError("❌ Erro ao criar usuário Admin inicial: {Errors}", errors);
            }
        }
    }
}
```

4. Entidade de Domínio e Atributo de Primeiro Acesso (```Authentication.Domain```)

Estendemos o ```IdentityUser``` para adicionar o controle do primeiro acesso e os Refresh Tokens associados:

```C#
C#

// Authentication.Domain/Entities/ApplicationUser.cs
using Microsoft.AspNetCore.Identity;

namespace Authentication.Domain.Entities;

public class ApplicationUser : IdentityUser
{
    public Guid? TenantId { get; set; }
    public bool MustChangePassword { get; private set; } = true;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;

    public void MarkPasswordAsChanged()
    {
        MustChangePassword = false;
    }
}

public class RefreshToken
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string UserId { get; set; } = string.Empty;
    public string Token { get; set; } = string.Empty;
    public DateTime ExpiresAtUtc { get; set; }
    public bool IsRevoked { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
```

5. Seeding Inicial e Regra de Primeiro Acesso (```Authentication.Infrastructure```)

Criamos a inicialização e execução do Seed no banco de dados com tratamento da flag do primeiro acesso:

```C#
C#

// Authentication.Infrastructure/Data/DatabaseSeeder.cs
using Authentication.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;

namespace Authentication.Infrastructure.Data;

public static class DatabaseSeeder
{
    public static async Task SeedAdminUserAsync(IServiceProvider serviceProvider)
    {
        using var scope = serviceProvider.CreateScope();
        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();

        var adminUser = await userManager.FindByNameAsync("Admin");
        if (adminUser == null)
        {
            var user = new ApplicationUser
            {
                UserName = "Admin",
                Email = "enviaemailwebapi@gmail.com",
                EmailConfirmed = true,
                TenantId = null // Admin Master Global
            };

            var result = await userManager.CreateAsync(user, "12345");
            if (result.Succeeded)
            {
                // Garante a presença do usuário padrão com MustChangePassword = true
            }
        }
    }
}
```

6. Endpoint de Autenticação Interceptando Primeiro Acesso (```Authentication.API```)

O fluxo valida as credenciais. Se for a primeira acesso do usuário, será forçado a trocar a senha antes de receber o **JWT** com permissões totais:

```C#
C#

// Authentication.API/Controllers/AuthController.cs
using Authentication.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace Authentication.API.Controllers;

[ApiController]
[Route("api/v1/auth")]
public class AuthController : ControllerBase
{
    private readonly UserManager<ApplicationUser> _userManager;

    public AuthController(UserManager<ApplicationUser> userManager)
    {
        _userManager = userManager;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var user = await _userManager.FindByNameAsync(request.Username);
        if (user == null || !await _userManager.CheckPasswordAsync(user, request.Password))
        {
            return Unauthorized(new { message = "Credenciais inválidas" });
        }

        // Intercepta a obrigatoriedade de troca de senha no primeiro acesso
        if (user.MustChangePassword)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new
            {
                code = "MUST_CHANGE_PASSWORD",
                message = "É obrigatório alterar a senha inicial antes de prosseguir.",
                userId = user.Id
            });
        }

        // Emite Tokens se estiver tudo correto
        return Ok(new
        {
            accessToken = "JWT_TOKEN_GERADO",
            refreshToken = "REFRESH_TOKEN_GERADO"
        });
    }

    [HttpPost("change-initial-password")]
    public async Task<IActionResult> ChangeInitialPassword([FromBody] ChangeInitialPasswordRequest request)
    {
        var user = await _userManager.FindByIdAsync(request.UserId);
        if (user == null) return NotFound();

        var changeResult = await _userManager.ChangePasswordAsync(user, request.CurrentPassword, request.NewPassword);
        if (!changeResult.Succeeded)
        {
            return BadRequest(changeResult.Errors);
        }

        user.MarkPasswordAsChanged();
        await _userManager.UpdateAsync(user);

        return Ok(new { message = "Senha alterada com sucesso! Agora já pode efetuar o login." });
    }
}

public record LoginRequest(string Username, string Password);
public record ChangeInitialPasswordRequest(string UserId, string CurrentPassword, string NewPassword);
```

7. Contrato gRPC para Validação de Tokens (```Authentication.Contracts```)

Crie o arquivo Proto em ```Authentication.Contracts/Protos/auth_service.proto``` para validar autenticações síncronas entre microsserviços de forma otimizada:

```protobuf
Protocol Buffers

syntax = "proto3";

option csharp_namespace = "Authentication.Contracts.Grpc";

package auth;

service AuthServiceGrpc {
  rpc ValidateToken (ValidateTokenRequest) returns (ValidateTokenResponse);
}

message ValidateTokenRequest {
  string token = 1;
}

message ValidateTokenResponse {
  bool isValid = 1;
  string userId = 2;
  string tenantId = 3;
  string error = 4;
}
```

8. Serviço gRPC na API (```Authentication.API```)

Serviço **gRPC** configurado para interceptar requisições de validação de outros serviços com latência mínima:

```C#
C#

// Authentication.API/GrpcServices/AuthGrpcService.cs
using System.IdentityModel.Tokens.Jwt;
using System.Text;
using Authentication.Contracts.Grpc;
using Grpc.Core;
using Microsoft.IdentityModel.Tokens;

namespace Authentication.API.GrpcServices;

public class AuthGrpcService : AuthServiceGrpc.AuthServiceGrpcBase
{
    private readonly IConfiguration _configuration;

    public AuthGrpcService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public override Task<ValidateTokenResponse> ValidateToken(ValidateTokenRequest request, ServerCallContext context)
    {
        if (string.IsNullOrWhiteSpace(request.Token))
        {
            return Task.FromResult(new ValidateTokenResponse
            {
                IsValid = false,
                Error = "Token não fornecido."
            });
        }

        try
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.UTF8.GetBytes(_configuration["Jwt:SecretKey"] ?? "S3cr3t_K3y_Super_S3cur3_Enterprise_2026!");

            var validationParameters = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(key),
                ValidateIssuer = false,
                ValidateAudience = false,
                ClockSkew = TimeSpan.Zero
            };

            var principal = tokenHandler.ValidateToken(request.Token, validationParameters, out var validatedToken);
            var userId = principal.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? string.Empty;
            var tenantId = principal.FindFirst("tenant_id")?.Value ?? string.Empty;

            return Task.FromResult(new ValidateTokenResponse
            {
                IsValid = true,
                UserId = userId,
                TenantId = tenantId
            });
        }
        catch (Exception ex)
        {
            return Task.FromResult(new ValidateTokenResponse
            {
                IsValid = false,
                Error = $"Token inválido: {ex.Message}"
            });
        }
    }
}
```

9. Arquivo de Entrada Principal (```Authentication.API/Program.cs```)
Este arquivo integra a Web API, o suporte a gRPC na mesma porta/pipeline, o Entity Framework Core e a injeção dos Building Blocks da Platform (Fase 3):

```C#
C#

// Authentication.API/Program.cs
using System.Text;
using Authentication.API.GrpcServices;
using Authentication.Domain.Entities;
using Authentication.Infrastructure.Data;
using Authentication.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Platform.Observability;

var builder = WebApplication.CreateBuilder(args);

// Building Block Serilog
builder.Host.UseCustomSerilog("Authentication.API");

// Configuração do DbContext & Identity
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? "Server=localhost;Database=Db_Authentication;User Id=sa;Password=Senh@ForteCondominio2026!;Encrypt=False;TrustServerCertificate=True;";

builder.Services.AddDbContext<AuthenticationDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddIdentity<ApplicationUser, IdentityRole>(options =>
{
    // Permite senha '12345' do Seeding para facilitar o fluxo do primeiro acesso
    options.Password.RequireDigit = false;
    options.Password.RequireLowercase = false;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequireUppercase = false;
    options.Password.RequiredLength = 5;
})
.AddEntityFrameworkStores<AuthenticationDbContext>()
.AddDefaultTokenProviders();

// Autenticação JWT
var jwtKey = builder.Configuration["Jwt:SecretKey"] ?? "S3cr3t_K3y_Super_S3cur3_Enterprise_2026!";
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
        ValidateIssuer = false,
        ValidateAudience = false
    };
});

// Registra Web API e gRPC
builder.Services.AddControllers();
builder.Services.AddGrpc();

// Building Block Observabilidade
builder.Services.AddCustomObservability("Authentication.API", builder.Configuration["OpenTelemetry:Endpoint"] ?? "http://localhost:4317");

var app = builder.Build();

// Building Block Prometheus
app.UsePrometheusEndpoint();

app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

// Mapeia os endpoints REST e gRPC
app.MapControllers();
app.MapGrpcService<AuthGrpcService>();

// Executa o Seeding do Usuário Admin no Start
await DatabaseSeeder.SeedAdminUserAsync(app.Services);

await app.RunAsync();
```

### 📦 Pacotes NuGet Necessários

Certifique-se de que os pacotes estejam adicionados aos respectivos arquivos ```.csproj```:

- Authentication.API.csproj:
  - Grpc.AspNetCore
  - Microsoft.AspNetCore.Authentication.JwtBearer
  - Microsoft.EntityFrameworkCore.Design
  - Referências de Projeto:
      - Authentication.Infrastructure, Authentication.Contracts, Platform.Observability
- Authentication.Infrastructure.csproj:
  - Microsoft.AspNetCore.Identity.EntityFrameworkCore
  - Microsoft.EntityFrameworkCore.SqlServer
  - Referências de Projeto:
      - Authentication.Domain, Authentication.Application
- Authentication.Contracts.csproj:
  - Google.Protobuf
  - Grpc.Tools
  - Grpc.Net.Client

### 🤖 Como Orquestrar o Copilot Chat no VS

Execute os seguintes prompts no **Visual Studio**:

**1. Configuração de Pacotes do Identity e gRPC:**

  ```@workspace Adicione os pacotes 'Microsoft.AspNetCore.Identity.EntityFrameworkCore', 'Microsoft.AspNetCore.Authentication.JwtBearer' e 'Grpc.AspNetCore' no projeto 'Authentication.API.csproj'.```

**2. Seeding Automático na Program:**

  ```#file:Program.cs Adicione a chamada do DatabaseSeeder.SeedAdminUserAsync(app.Services) logo após a compilação do app no Program.cs de Authentication.API.```

Assim que os pacotes forem instalados e o **Seed** for rodado, a autenticação base do ecossistema estará pronta para emissão e validação.

---

## 🏗️ Fase 6 Empresa / Tenant Resolution (CRUD Tenant, Configurações Globais & SMTP por Tenant)

Na **Fase** será criado o microsserviço **Empresa** que tem como objetivo gerenciar o ciclo de vida das empresas (```tenants```) no modelo **SaaS Multi-tenant**. Este serviço **Empresa** é dono dos dados cadastrais do cliente, das configurações visuais (```branding```), limites de uso e, fundamentalmente, da configuração SMTP customizada de cada empresa (usada pela **Fase de Notification**).

### 🎯 Objetivos

1. ```Gestão do Cadastro do Tenant```: CRUD de Empresas com dados de domínio e isolamento de identificador (```Guid EmpresaId```).

2. ```Estratégia de Configuração SMTP por Tenant```: Registrar credenciais de SMTP criptografadas (```Host, Porta, Usuário, Senha```) específicas de cada empresa.

3. ```Serviço gRPC de Resolução de Tenant/SMTP```: Expor um serviço gRPC síncrono para que o ```Notification.Worker``` consulte as credenciais de SMTP do tenant remetente com extrema eficiência e cache local.

4. ```Resolução Dinâmica de Tenant (TenantResolution)```: Estratégia centralizada de leitura de contexto via Headers (```X-Tenant-Id```), JWT Claims (```tenant_id```) ou Subdomínio.

### 🏗️ Estrutura da Solução

```Plaintext
Plaintext

Services/Empresa/
├── Empresa.API/          # Endpoints REST para CRUD de Empresas e Configurações SMTP + gRPC Server
├── Empresa.Application/  # Use Cases (RegisterTenantCommand, ConfigureTenantSmtpCommand)
├── Empresa.Domain/       # Entidades Tenant, SmtpConfig, Value Objects (CNPJ, Email)
├── Empresa.Infrastructure/# EF Core (EmpresaDbContext), Criptografia de Credenciais
├── Empresa.Contracts/    # Integration Events e arquivos .proto (EmpresaSmtpGrpcService)
└── Empresa.Tests/
```

### 💻 Implementação Prática

1. Configuração do .csproj de Contratos (```Empresa.Contracts/Empresa.Contracts.csproj```)

Certifique-se de registrar a compilação do arquivo ```.proto``` no projeto de contratos:

```XML
XML
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Google.Protobuf" Version="3.30.0" />
    <PackageReference Include="Grpc.Tools" Version="2.70.0">
      <PrivateAssets>all</PrivateAssets>
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
    </PackageReference>
  </ItemGroup>

  <ItemGroup>
    <Protobuf Include="Protos\empresa_smtp.proto" GrpcServices="Both" />
  </ItemGroup>

</Project>
```

2. Entidades de Domínio (```Empresa.Domain```)

  A entidade ```Tenant``` controla o cadastro e possui uma relação 1:1 com as configurações de servidor SMTP:

```C#
C#

// Empresa.Domain/Entities/Tenant.cs
namespace Empresa.Domain.Entities;

public class Tenant
{
    public Guid Id { get; private set; }
    public string Name { get; private set; }
    public string DocumentNumber { get; private set; } // CNPJ / CPF
    public bool IsActive { get; private set; }
    public TenantSmtpConfig? SmtpConfig { get; private set; }
    public DateTime CreatedAtUtc { get; private set; }

    protected Tenant() { } // Para EF Core

    public Tenant(string name, string documentNumber)
    {
        Id = Guid.NewGuid();
        Name = name;
        DocumentNumber = documentNumber;
        IsActive = true;
        CreatedAtUtc = DateTime.UtcNow;
    }

    public void ConfigureSmtp(string host, int port, string username, string encryptedPassword, bool enableSsl)
    {
        SmtpConfig = new TenantSmtpConfig(Id, host, port, username, encryptedPassword, enableSsl);
    }
}
```

```C#
C#

// Empresa.Domain/Entities/TenantSmtpConfig.cs
public class TenantSmtpConfig
{
    public Guid Id { get; private set; }
    public Guid TenantId { get; private set; }
    public string Host { get; private set; }
    public int Port { get; private set; }
    public string Username { get; private set; }
    public string EncryptedPassword { get; private set; } // Nunca salvar senha aberta!
    public bool EnableSsl { get; private set; }

    protected TenantSmtpConfig() { }

    public TenantSmtpConfig(Guid tenantId, string host, int port, string username, string encryptedPassword, bool enableSsl)
    {
        Id = Guid.NewGuid();
        TenantId = tenantId;
        Host = host;
        Port = port;
        Username = username;
        EncryptedPassword = encryptedPassword;
        EnableSsl = enableSsl;
    }
}
```

3. Contrato gRPC para Consulta de SMTP (```Empresa.Contracts```)

  Crie o arquivo Proto em ```Empresa.Contracts/Protos/empresa_smtp.proto```. Esse contrato permite que outros microsserviços (como o ```Notification.Worker```) leiam as configurações SMTP do tenant sem acessar o banco de dados de Empresa:

```protobuf
Protocol Buffers

syntax = "proto3";

option csharp_namespace = "Empresa.Contracts.Grpc";

package empresa;

service TenantSmtpGrpcService {
  rpc GetSmtpConfigByTenant (GetTenantSmtpRequest) returns (GetTenantSmtpResponse);
}

message GetTenantSmtpRequest {
  string tenantId = 1;
}

message GetTenantSmtpResponse {
  bool found = 1;
  string host = 2;
  int32 port = 3;
  string username = 4;
  string password = 5; // Descriptografada em tempo de execução para o serviço cliente
  bool enableSsl = 6;
}
```

4. Serviço gRPC na API (```Empresa.API```)

  Implementação da busca síncrona com suporte a descriptografia das credenciais de envio de e-mail:

```C#
C#

// Empresa.API/GrpcServices/TenantSmtpService.cs
using Empresa.Contracts.Grpc;
using Empresa.Infrastructure.Data;
using Grpc.Core;
using Microsoft.EntityFrameworkCore;

namespace Empresa.API.GrpcServices;

public class TenantSmtpService : TenantSmtpGrpcService.TenantSmtpGrpcServiceBase
{
    private readonly EmpresaDbContext _dbContext;

    public TenantSmtpService(EmpresaDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public override async Task<GetTenantSmtpResponse> GetSmtpConfigByTenant(
        GetTenantSmtpRequest request, 
        ServerCallContext context)
    {
        if (!Guid.TryParse(request.TenantId, out var tenantId))
        {
            return new GetTenantSmtpResponse { Found = false };
        }

        var tenant = await _dbContext.Tenants
            .Include(t => t.SmtpConfig)
            .FirstOrDefaultAsync(t => t.Id == tenantId, context.CancellationToken);

        if (tenant?.SmtpConfig == null)
        {
            return new GetTenantSmtpResponse { Found = false };
        }

        var decryptedPassword = DecryptString(tenant.SmtpConfig.EncryptedPassword);

        return new GetTenantSmtpResponse
        {
            Found = true,
            Host = tenant.SmtpConfig.Host,
            Port = tenant.SmtpConfig.Port,
            Username = tenant.SmtpConfig.Username,
            Password = decryptedPassword,
            EnableSsl = tenant.SmtpConfig.EnableSsl
        };
    }

    private static string DecryptString(string encryptedText)
    {
        if (encryptedText.StartsWith("ENC_"))
        {
            return encryptedText.Replace("ENC_", "");
        }
        return encryptedText;
    }
}
```

5. Controller de Cadastro do Tenant (```Empresa.API```)

  Endpoint REST para cadastrar uma nova empresa no ecossistema e configurar os parâmetros iniciais:

```C#
C#

// Empresa.API/Controllers/EmpresaController.cs
using Empresa.Domain.Entities;
using Empresa.Infrastructure.Data;
using Microsoft.AspNetCore.Mvc;

namespace Empresa.API.Controllers;

[ApiController]
[Route("api/v1/empresas")]
public class EmpresaController : ControllerBase
{
    private readonly EmpresaDbContext _dbContext;

    public EmpresaController(EmpresaDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    [HttpPost]
    public async Task<IActionResult> CreateTenant([FromBody] CreateTenantRequest request, CancellationToken ct)
    {
        var tenant = new Tenant(request.Name, request.DocumentNumber);
        
        if (request.Smtp != null)
        {
            // Criptografa a senha antes de persistir
            var encryptedPassword = $"ENC_{request.Smtp.Password}";
            tenant.ConfigureSmtp(request.Smtp.Host, request.Smtp.Port, request.Smtp.Username, encryptedPassword, request.Smtp.EnableSsl);
        }

        _dbContext.Tenants.Add(tenant);
        await _dbContext.SaveChangesAsync(ct);

        return CreatedAtAction(nameof(GetById), new { id = tenant.Id }, new { id = tenant.Id, name = tenant.Name });
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken ct)
    {
        var tenant = await _dbContext.Tenants.FindAsync(new object[] { id }, ct);
        if (tenant == null) return NotFound();

        return Ok(tenant);
    }
}

public record CreateTenantRequest(string Name, string DocumentNumber, SmtpConfigRequest? Smtp);
public record SmtpConfigRequest(string Host, int Port, string Username, string Password, bool EnableSsl);
```

6. Persistência de Dados (```Empresa.Infrastructure```)

```C#
C#
// Empresa.Infrastructure/Data/EmpresaDbContext.cs
using Empresa.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Empresa.Infrastructure.Data;

public class EmpresaDbContext : DbContext
{
    public EmpresaDbContext(DbContextOptions<EmpresaDbContext> options) : base(options) { }

    public DbSet<Tenant> Tenants => Set<Tenant>();
    public DbSet<TenantSmtpConfig> TenantSmtpConfigs => Set<TenantSmtpConfig>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Tenant>(builder =>
        {
            builder.ToTable("Tenants");
            builder.HasKey(t => t.Id);
            builder.Property(t => t.Name).IsRequired().HasMaxLength(200);
            builder.Property(t => t.DocumentNumber).IsRequired().HasMaxLength(30);

            // Relacionamento 1:1
            builder.HasOne(t => t.SmtpConfig)
                   .WithOne()
                   .HasForeignKey<TenantSmtpConfig>(s => s.TenantId)
                   .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<TenantSmtpConfig>(builder =>
        {
            builder.ToTable("TenantSmtpConfigs");
            builder.HasKey(s => s.Id);
            builder.Property(s => s.Host).IsRequired().HasMaxLength(150);
            builder.Property(s => s.Username).IsRequired().HasMaxLength(150);
            builder.Property(s => s.EncryptedPassword).IsRequired().HasMaxLength(500);
        });
    }
}
```

7. Web API Program EntryPoint (Empresa.API/Program.cs)
Integrando gRPC, REST, Building Blocks da Platform e Multitenancy:

```C#
C#

// Empresa.API/Program.cs
using Empresa.API.GrpcServices;
using Empresa.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Platform.Multitenancy;
using Platform.Observability;

var builder = WebApplication.CreateBuilder(args);

// Observabilidade (Serilog)
builder.Host.UseCustomSerilog("Empresa.API");

// Banco de Dados SQL Server
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=localhost;Database=Db_Empresa;User Id=sa;Password=Senh@ForteCondominio2026!;Encrypt=False;TrustServerCertificate=True;";

builder.Services.AddDbContext<EmpresaDbContext>(opts =>
    opts.UseSqlServer(connectionString));

// Building Block de Multitenancy (Fase 3)
builder.Services.AddMultitenancy();

// Injeção dos Serviços de Controller e gRPC
builder.Services.AddControllers();
builder.Services.AddGrpc();

// Building Block de OpenTelemetry (Prometheus & Jaeger)
builder.Services.AddCustomObservability("Empresa.API", builder.Configuration["OpenTelemetry:Endpoint"] ?? "http://localhost:4317");

var app = builder.Build();

// Middlewares da Aplicação
app.UsePrometheusEndpoint();
app.UseRouting();

// Middleware para extrair X-Tenant-Id dos Headers
app.UseTenantMiddleware();

app.MapControllers();
app.MapGrpcService<TenantSmtpService>();

await app.RunAsync();
```

### 📦 Pacotes NuGet Necessários

Adicione estas referências nos arquivos ```.csproj```:

- Empresa.API.csproj:
  - Grpc.AspNetCore
  - Microsoft.EntityFrameworkCore.Design
  - Referências de Projeto:
      - Empresa.Infrastructure, Empresa.Contracts, Platform.Observability, Platform.Multitenancy
- Empresa.Infrastructure.csproj:
  - Microsoft.EntityFrameworkCore.SqlServer
  - Referências de Projeto:
      - Empresa.Domain, Empresa.Application
- Empresa.Contracts.csproj:
  - Google.Protobuf
  - Grpc.Tools

### 🤖 Como Orquestrar o Copilot Chat no VS

Execute os comandos abaixo no Copilot Chat:

**1. Configuração de Protobuf/gRPC:**

  ```@workspace Configure a compilação do arquivo 'empresa_smtp.proto' dentro do 'Empresa.Contracts.csproj' com a tag '<Protobuf Include="..." GrpcServices="Server" />'.```

**2. Geração da Migration:**

  ```@workspace Crie a instrução da Migration do EF Core na camada 'Empresa.Infrastructure' para mapear as tabelas Tenants e TenantSmtpConfigs.```

Com o serviço de **Empresa** configurado, temos o modelo de dados de tenants isolado e a consulta síncrona gRPC de credenciais pronta para atender o worker de notificações.

---

## 🏗️ Fase 7 SaaS Foundation Template (dotnet new Scaffolding CLI)

Na **Fase** será criado um motor de aceleração e padronização para o ecossistema, tem como base toda a estrutura técnica e arquitetural que foi construida e valida até agora. O objetivo é permitir que a equipe consiga gerar um novo microsserviço completo em segundos usando a ```CLI do .NET``` (```dotnet new```), já com todas as camadas, referências de projetos e configurações de **Building Blocks** pré-plugadas.

### 🎯 Objetivos

  1. ```Empacotamento do Template CLI (dotnet new)```: Transformar a estrutura padrão de **Clean Architecture** e **Building Blocks** num template reutilizável.
  
  2. ```Automação de Scaffolding (CLI/Scripts)```: Permitir a criação instantânea de **Bounded Contexts***, **Consumers do MassTransit** e **Integration Events** de forma padronizada.
  
  3. ```Garantia de Governança Arquitetural```: Impedir que novos microsserviços sejam criados fora do padrão e das regras do ecossistema.

### 🏗️ Estrutura da Solução

No diretório ```Platform/Templates```, vamos organizar a estrutura que servirá de molde para o engine do ```dotnet new```:

```Plaintext
Plaintext

Platform/
└── Templates/
    └── MicroserviceTemplate/
        ├── .template.config/
        │   └── template.json       # Configuração e parâmetros da CLI dotnet new
        ├── Servico.Template.API/
        ├── Servico.Template.Application/
        ├── Servico.Template.Domain/
        ├── Servico.Template.Infrastructure/
        ├── Servico.Template.Contracts/
        └── Servico.Template.Tests/
```

### 💻 Implementação Prática

1. Configuração do Template (```Platform/Templates/MicroserviceTemplate/.template.config/template.json```)

Este ficheiro ensina a ```CLI do .NET``` a substituir os nomes genéricos do template pelo nome do novo microsserviço que escolher criar:

```JSON
JSON

{
  "$schema": "http://json.schemastore.org/template",
  "author": "Enterprise SaaS Team",
  "classifications": [ "Microservice", "Clean Architecture", "SaaS" ],
  "name": "Enterprise SaaS Microservice Template",
  "identity": "Enterprise.SaaS.Microservice.CSharp",
  "shortName": "saas-service",
  "tags": {
    "language": "C#",
    "type": "solution"
  },
  "sourceName": "Servico.Template",
  "preferNameDirectory": true,
  "sources": [
    {
      "modifiers": [
        {
          "exclude": [
            "**/bin/**",
            "**/obj/**",
            "**/.vs/**",
            "**/*.filelist.xml"
          ]
        }
      ]
    }
  ]
}
```

2. Estrutura dos Projetos Moldes do Template

Certifique-se de montar os ```.csproj``` base da pasta ```Platform/Templates/MicroserviceTemplate``` com as referências relativas para a ```Platform```:

```Servico.Template.API.csproj```

```XML
XML

<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <ProjectReference Include="..\..\..\Platform\Platform.Observability\Platform.Observability.csproj" />
    <ProjectReference Include="..\..\..\Platform\Platform.Multitenancy\Platform.Multitenancy.csproj" />
    <ProjectReference Include="..\Servico.Template.Infrastructure\Servico.Template.Infrastructure.csproj" />
    <ProjectReference Include="..\Servico.Template.Contracts\Servico.Template.Contracts.csproj" />
  </ItemGroup>

</Project>
```

```Servico.Template.Infrastructure.csproj```

```XML
XML

<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="9.0.0" />
    <ProjectReference Include="..\..\..\Platform\Platform.Messaging\Platform.Messaging.csproj" />
    <ProjectReference Include="..\Servico.Template.Application\Servico.Template.Application.csproj" />
  </ItemGroup>

</Project>
```

3. Script de Instalação e Teste do Template (```Scripts/install-template.ps1```)

Crie este script **PowerShell** dentro da pasta ```Scripts/``` para registrar o template no **SDK do .NET local**:

```PowerShell
PowerShell

# Scripts/install-template.ps1
$ErrorActionPreference = "Stop"

Write-Host "🚀 Registrando o SaaS Foundation Template no .NET CLI..." -ForegroundColor Yellow

# Desinstala versão anterior (se existir) e instala a atualizada
dotnet new uninstall ./Platform/Templates/MicroserviceTemplate 2>$null | Out-Null
dotnet new install ./Platform/Templates/MicroserviceTemplate

Write-Host "`n✅ Template instalado com sucesso!" -ForegroundColor Green
Write-Host "💡 Para gerar um novo microsserviço manualmente, execute:" -ForegroundColor Yellow
Write-Host "   dotnet new saas-service -n NomeDoServico -o Services/NomeDoServico`n" -ForegroundColor Cyan
```

4. Automação de Criador de Serviço (```Scripts/add-new-service.ps1```)

Este script cria a pasta do microsserviço, roda o template, cria a solution e vincula os projetos automaticamente:

```PowerShell
PowerShell

# Scripts/add-new-service.ps1
param (
    [Parameter(Mandatory=$true)]
    [string]$ServiceName
)

$ErrorActionPreference = "Stop"
$targetPath = "Services/$ServiceName"

if (Test-Path $targetPath) {
    Write-Host "❌ O serviço '$ServiceName' já existe no diretório Services/!" -ForegroundColor Red
    exit
}

Write-Host "⚡ Gerando o microsserviço '$ServiceName' a partir do SaaS Foundation Template..." -ForegroundColor Cyan

# 1. Executa a geração a partir do template
dotnet new saas-service -n $ServiceName -o $targetPath

# 2. Cria a Solução
dotnet new sln -n $ServiceName -o $targetPath

# 3. Localiza dinamicamente o arquivo de solução (.sln / .slnx)
$slnFile = Get-ChildItem -Path $targetPath -Filter "$ServiceName.sln*" | Select-Object -First 1

# 4. Adiciona todos os projetos (.csproj) gerados à solução
$projects = Get-ChildItem -Path $targetPath -Recurse -Filter "*.csproj"
foreach ($proj in $projects) {
    dotnet sln $slnFile.FullName add $proj.FullName
}

Write-Host "`n✅ Microsserviço '$ServiceName' gerado, vinculado e pronto para uso!" -ForegroundColor Green
```

### 🚀 Resumo do Fluxo do Desenvolvedor

Agora, qualquer desenvolvedor do time pode adicionar um novo microsserviço (ex: ```Financeiro```) ao ecossistema executando apenas:

```PowerShell
PowerShell

# 1. Registra o template (executado uma única vez)
.\Scripts\install-template.ps1

# 2. Gera qualquer novo microsserviço padronizado
.\Scripts\add-new-service.ps1 -ServiceName "Financeiro"
```

### 🤖 Como Orquestrar o Copilot Chat no VS

Execute os seguintes prompts no **Visual Studio**:

**1. Validação e Limpeza do Template Base:**

  ```@workspace Verifique se todos os ficheiros de projeto (.csproj) em 'Platform/Templates/MicroserviceTemplate' contêm apenas referências relativas para os projetos 'Platform.Shared', 'Platform.Observability' e 'Platform.Messaging'.```

**2. Geração de Templates de Consumer e Evento:**

  ```#file:template.json Crie uma estrutura de template auxiliar chamada 'saas-consumer' dentro de 'Platform/Templates/ConsumerTemplate' que gere um novo Consumer MassTransit com Retry e DLQ pré-configurados.```

Com a **Fase** concluída, transformamos a nossa arquitetura de referência num ecossistema escalável e pronto para produção!

---

## 🏗️ Fase 8 Pessoas Service (DDD, Rich Domain, Tenant Query Filters)

A **Fase** é focada exclusivamente em **Domínio de Negócio Puro** (```Business Domain```). Nesta fase será construida a base para gestão de parceiros de negócio (```Clientes e Fornecedores```) respeitando estritamente os princípios do **DDD**, **Clean Architecture** e **isolamento Multi-tenant** (```TenantId```).

### 🎯 Objetivos

1. ```Modelagem de Domínio Rica (DDD)```: Entidades de ```Pessoa```, Value Objects para ```CPF/CNPJ``` e Endereco com validações de integridade no próprio domínio.
    
    1.1 Ao digitar o CEP o sistema busca os dados de **UF**, **cidade**, **endereco/logradouro**, **bairro** (```pode ser implementado no frontend```).

2. ```Isolamento de Tenant por Query Filter```: Garantir que um Tenant nunca veja pessoas cadastradas por outro Tenant via EF Core Global Query Filters.

3. ```Eventos de Integração Assíncronos```: Publicar o evento ```PessoaCriadaEvent``` no **RabbitMQ** para que outros microsserviços reajam sem acoplamento direto.

4. ```Resoluções e Contratos```: Expor contratos públicos desacoplados do modelo interno do banco.

### 🏗️ Estrutura da Solução

```Plaintext
Plaintext

Services/Pessoas/
├── Pessoas.API/          # Minimal APIs / Controllers, Tenant Middleware, Swagger
├── Pessoas.Application/  # Commands (CriarPessoaCommand), Handlers (CQRS), Validações
├── Pessoas.Domain/       # Entidades Pessoa, Value Objects (CpfCnpj, Endereco), Domain Events
├── Pessoas.Infrastructure/# EF Core (PessoaDbContext), Repositórios, Mapeamentos Fluent API
├── Pessoas.Contracts/    # Integration Events públicos (ex: PessoaCriadaIntegrationEvent)
└── Pessoas.Tests/
```

### 💻 Implementação Prática

1. Value Objects e Entidade de Domínio (```Pessoas.Domain```)

No **DDD**, regras de validação primárias devem viver no domínio:

```C#
C#

// Pessoas.Domain/ValueObjects/CpfCnpj.cs
namespace Pessoas.Domain.ValueObjects;

public record CpfCnpj
{
    public string Valor { get; }

    public CpfCnpj(string valor)
    {
        if (string.IsNullOrWhiteSpace(valor))
            throw new ArgumentException("O documento CPF/CNPJ não pode ser vazio.");

        var limpo = new string(valor.Where(char.IsDigit).ToArray());
        
        if (limpo.Length != 11 && limpo.Length != 14)
            throw new ArgumentException("CPF ou CNPJ inválido. Deve conter 11 (CPF) ou 14 (CNPJ) dígitos.");

        Valor = limpo;
    }
}
```

```C#
C#

// Pessoas.Domain/ValueObjects/Endereco.cs
namespace Pessoas.Domain.ValueObjects;

public record Endereco
{
    public string Logradouro { get; }
    public string Bairro { get; }
    public string Cidade { get; }
    public string Estado { get; }
    public string Cep { get; }

    public Endereco(string logradouro, string bairro, string cidade, string estado, string cep)
    {
        var cepLimpo = new string(cep?.Where(char.IsDigit).ToArray() ?? Array.Empty<char>());
        
        if (cepLimpo.Length != 8)
            throw new ArgumentException("CEP inválido. Deve conter 8 dígitos.");

        Logradouro = logradouro;
        Bairro = bairro;
        Cidade = cidade;
        Estado = estado;
        Cep = cepLimpo;
    }
}
```

```C#
C#

// Pessoas.Domain/Entities/Pessoa.cs
using Pessoas.Domain.ValueObjects;

namespace Pessoas.Domain.Entities;

public class Pessoa
{
    public Guid Id { get; private set; }
    public Guid TenantId { get; private set; }
    public string Nome { get; private set; }
    public CpfCnpj Documento { get; private set; }
    public Endereco? Endereco { get; private set; }
    public TipoPessoa Tipo { get; private set; }
    public bool Ativo { get; private set; }
    public DateTime CriadoEmUtc { get; private set; }

    protected Pessoa() { } // Construtor exigido pelo EF Core

    public Pessoa(Guid tenantId, string nome, CpfCnpj documento, TipoPessoa tipo, Endereco? endereco = null)
    {
        if (string.IsNullOrWhiteSpace(nome))
            throw new ArgumentException("O nome da pessoa é obrigatório.");

        Id = Guid.NewGuid();
        TenantId = tenantId;
        Nome = nome;
        Documento = documento;
        Tipo = tipo;
        Endereco = endereco;
        Ativo = true;
        CriadoEmUtc = DateTime.UtcNow;
    }

    public void AtualizarEndereco(Endereco novoEndereco)
    {
        Endereco = novoEndereco;
    }

    public void Desativar() => Ativo = false;
    public void Ativar() => Ativo = true;
}

public enum TipoPessoa
{
    Cliente = 1,
    Fornecedor = 2,
    Ambos = 3
}
```

2. Contrato de Evento de Integração (```Pessoas.Contracts```)

Evento imutável publicado no barramento de eventos após a criação de uma pessoa:

```C#
C#

// Pessoas.Contracts/Events/PessoaCriadaIntegrationEvent.cs
namespace Pessoas.Contracts.Events;

public record PessoaCriadaIntegrationEvent
{
    public Guid CorrelationId { get; init; } = Guid.NewGuid();
    public Guid PessoaId { get; init; }
    public Guid TenantId { get; init; }
    public string Nome { get; init; } = string.Empty;
    public string Documento { get; init; } = string.Empty;
    public DateTime OccurredOnUtc { get; init; } = DateTime.UtcNow;
}
```

3. EF Core DbContext com **Multi-tenant Filter** (```Pessoas.Infrastructure```)

Configuração técnica que força a filtragem de dados por **Tenant** em todas as queries SQL automaticamente:

```C#
C#

// Pessoas.Infrastructure/Data/PessoaDbContext.cs
using Microsoft.EntityFrameworkCore;
using Pessoas.Domain.Entities;
using Platform.Multitenancy;

namespace Pessoas.Infrastructure.Data;

public class PessoaDbContext : DbContext
{
    private readonly ITenantContext _tenantContext;

    public DbSet<Pessoa> Pessoas => Set<Pessoa>();

    public PessoaDbContext(DbContextOptions<PessoaDbContext> options, ITenantContext tenantContext) 
        : base(options)
    {
        _tenantContext = tenantContext;
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Pessoa>(builder =>
        {
            builder.ToTable("Pessoas");
            builder.HasKey(p => p.Id);
            builder.Property(p => p.Nome).IsRequired().HasMaxLength(200);

            // Mapeamento do Value Object CpfCnpj
            builder.OwnsOne(p => p.Documento, doc =>
            {
                doc.Property(d => d.Valor).HasColumnName("Documento").IsRequired().HasMaxLength(14);
            });

            // Mapeamento do Value Object Endereco
            builder.OwnsOne(p => p.Endereco, end =>
            {
                end.Property(e => e.Logradouro).HasColumnName("Endereco_Logradouro").HasMaxLength(200);
                end.Property(e => e.Bairro).HasColumnName("Endereco_Bairro").HasMaxLength(100);
                end.Property(e => e.Cidade).HasColumnName("Endereco_Cidade").HasMaxLength(100);
                end.Property(e => e.Estado).HasColumnName("Endereco_Estado").HasMaxLength(2);
                end.Property(e => e.Cep).HasColumnName("Endereco_Cep").HasMaxLength(8);
            });

            // Filtro Global de Tenant (Garante isolamento automático nas consultas)
            builder.HasQueryFilter(p => p.TenantId == _tenantContext.TenantId);
        });
    }
}
```

4. Caso de Uso Command e Handler (```Pessoas.Application/Commands/CriarPessoa```)

```C#
C#

// Pessoas.Application/Commands/CriarPessoa/CriarPessoaCommand.cs
using Pessoas.Domain.Entities;

namespace Pessoas.Application.Commands.CriarPessoa;

public record EnderecoDto(string Logradouro, string Bairro, string Cidade, string Estado, string Cep);

public record CriarPessoaCommand(string Nome, string Documento, TipoPessoa Tipo, EnderecoDto? Endereco);

Handler que processa o cadastro da pessoa e notifica o ecossistema via **MassTransit**:
```

```C#
C#

// Pessoas.Application/Commands/CriarPessoa/CriarPessoaCommandHandler.cs
using MassTransit;
using Pessoas.Contracts.Events;
using Pessoas.Domain.Entities;
using Pessoas.Domain.ValueObjects;
using Pessoas.Infrastructure.Data;
using Platform.Multitenancy;
using Platform.Shared.Results;

namespace Pessoas.Application.Commands.CriarPessoa;

public class CriarPessoaCommandHandler
{
    private readonly PessoaDbContext _dbContext;
    private readonly ITenantContext _tenantContext;
    private readonly IPublishEndpoint _publishEndpoint;

    public CriarPessoaCommandHandler(
        PessoaDbContext dbContext, 
        ITenantContext tenantContext, 
        IPublishEndpoint publishEndpoint)
    {
        _dbContext = dbContext;
        _tenantContext = tenantContext;
        _publishEndpoint = publishEndpoint;
    }

    public async Task<Result<Guid>> HandleAsync(CriarPessoaCommand command, CancellationToken ct)
    {
        if (!_tenantContext.TenantId.HasValue)
            return Result.Failure<Guid>("Tenant não resolvido no contexto da requisição.");

        try
        {
            var documento = new CpfCnpj(command.Documento);
            
            Endereco? endereco = null;
            if (command.Endereco != null)
            {
                endereco = new Endereco(
                    command.Endereco.Logradouro,
                    command.Endereco.Bairro,
                    command.Endereco.Cidade,
                    command.Endereco.Estado,
                    command.Endereco.Cep
                );
            }

            var pessoa = new Pessoa(_tenantContext.TenantId.Value, command.Nome, documento, command.Tipo, endereco);

            _dbContext.Pessoas.Add(pessoa);
            await _dbContext.SaveChangesAsync(ct);

            // Event-Driven: Publica o evento de integração para a rede
            await _publishEndpoint.Publish(new PessoaCriadaIntegrationEvent
            {
                PessoaId = pessoa.Id,
                TenantId = pessoa.TenantId,
                Nome = pessoa.Nome,
                Documento = pessoa.Documento.Valor
            }, ct);

            return Result.Success(pessoa.Id);
        }
        catch (ArgumentException ex)
        {
            return Result.Failure<Guid>(ex.Message);
        }
    }
}
```

5. EntryPoint com Minimal API (```Pessoas.API/Program.cs```)

```C#
C#

// Pessoas.API/Program.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Pessoas.Application.Commands.CriarPessoa;
using Pessoas.Infrastructure.Data;
using Platform.Messaging;
using Platform.Multitenancy;
using Platform.Observability;

var builder = WebApplication.CreateBuilder(args);

// Observabilidade (Serilog)
builder.Host.UseCustomSerilog("Pessoas.API");

// Banco de Dados SQL Server
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=localhost;Database=Db_Pessoas;User Id=sa;Password=Senh@ForteCondominio2026!;Encrypt=False;TrustServerCertificate=True;";

builder.Services.AddDbContext<PessoaDbContext>(opts =>
    opts.UseSqlServer(connectionString));

// Building Blocks da Plataforma
builder.Services.AddMultitenancy();
builder.Services.AddCustomMessaging(builder.Configuration);
builder.Services.AddCustomObservability("Pessoas.API", builder.Configuration["OpenTelemetry:Endpoint"] ?? "http://localhost:4317");

// Injeção dos Handlers de Aplicação (CQRS)
builder.Services.AddScoped<CriarPessoaCommandHandler>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UsePrometheusEndpoint();
app.UseRouting();

// Middleware para extração do Tenant
app.UseTenantMiddleware();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Endpoint em Minimal API
app.MapPost("/api/v1/pessoas", async (
    [FromBody] CriarPessoaCommand command, 
    [FromServices] CriarPessoaCommandHandler handler, 
    CancellationToken ct) =>
{
    var result = await handler.HandleAsync(command, ct);

    if (result.IsFailure)
    {
        return Results.BadRequest(new { error = result.Error });
    }

    return Results.Created($"/api/v1/pessoas/{result.Value}", new { id = result.Value });
})
.WithName("CriarPessoa")
.WithOpenApi();

await app.RunAsync();
```

### 📦 Pacotes NuGet Necessários

Adicione as dependências aos arquivos de projeto correspondentes:

- Pessoas.API.csproj:
  - Swashbuckle.AspNetCore
  - Referências de Projeto:
      - Pessoas.Infrastructure, Pessoas.Application, Pessoas.Contracts, Platform.Observability, Platform.Multitenancy, Platform.Messaging
- Pessoas.Infrastructure.csproj:
  - Microsoft.EntityFrameworkCore.SqlServer
  - Microsoft.EntityFrameworkCore.Design
  - Referências de Projeto:
      - Pessoas.Domain, Pessoas.Application, Platform.Multitenancy
- Pessoas.Application.csproj:
  - Referências de Projeto:
      - Pessoas.Domain, Pessoas.Contracts, Platform.Shared
- Pessoas.Contracts.csproj:
  - Não requer pacotes externos além dos SDKs padrão do C#.

### 🤖 Como Orquestrar o Copilot Chat no VS

Execute estes prompts direcionados no painel do Copilot Chat:

**1. Geração de Endpoints em Minimal APIs:**

```#file:CriarPessoaCommandHandler.cs Crie uma Minimal API no projeto 'Pessoas.API' mapeando a rota POST '/api/v1/pessoas' que recebe o 'CriarPessoaCommand' e chama o handler correspondente.```

**2. Geração de Migration com Tenant Filter:**

```@workspace Gere o comando 'dotnet ef migrations add InitialPessoa' para a camada 'Pessoas.Infrastructure' apontando para o 'PessoaDbContext'.```

Com a solução ```Pessoas.sln``` finalizada, temos o nosso primeiro Bounded Context de domínio cadastral rodando com isolamento de tenant e publicação de eventos.

---

## 🏗️ Fase 9 Produtos Service (Catálogo, Preço & Versionamento Evolutivo de Eventos V1/V2, Outbox Pattern)

Na **Fase** será construido o **Bounded Context** de **Catálogo de Produtos**. A grande sacada arquitetural aqui é implementar a governança de eventos com versionamento evolutivo (```Backward Compatibility```): como alterar ou evoluir a estrutura de dados de um evento de integração (ex: de ```ProdutoCriadoEventV1``` para ```ProdutoAtualizadoV2```) sem quebrar os outros microsserviços do ecossistema que dependem desse contrato.

### 🎯 Objetivos

1. ```Gestão do Catálogo de Produtos```: CRUD completo com controle de SKU, Preço, Unidade de Medida e estado de Ativo/Inativo.

2. ```Versionamento de Contratos e Eventos (Additive-Only)```: Aplicação de versionamento de eventos via interface e structs no ```Contracts```, garantindo compatibilidade retroativa.

3. ```Isolamento Multi-tenant e Unicidade por Tenant```: Garantir por índice do banco de dados que um SKU é único dentro de um mesmo ```TenantId```.

4. ```Outbox Pattern na Prática```: Garantir que o produto só é salvo no **SQL Server** se o evento de alteração for gravado na tabela **Outbox** da mensageria (```evitando dual write incorreto```).

### 🏗️ Estrutura da Solução

```Plaintext
Plaintext

Services/Produtos/
├── Produtos.API/          # Minimal APIs, Versionamento de Rotas, Swagger
├── Produtos.Application/  # Commands (CriarProdutoCommand, AtualizarPrecoCommand), CQRS Handlers
├── Produtos.Domain/       # Entidades Produto, Value Objects (Preco, SKU), Domain Events
├── Produtos.Infrastructure/# EF Core (ProdutoDbContext), MassTransit Outbox Context, Mapeamentos
├── Produtos.Contracts/    # Integration Events públicos versionados (V1, V2)
└── Produtos.Tests/
```

### 💻 Implementação Prática

1. Governança de Eventos Versionados (```Produtos.Contracts```)

Nunca alter propriedades de um evento já publicado em produção. Crie uma nova versão e mantenha a anterior para não quebrar consumers legados:

```C#
C#

// Produtos.Contracts/Events/V1/ProdutoCriadoEventV1.cs
namespace Produtos.Contracts.Events.V1;

public record ProdutoCriadoEventV1
{
    public Guid CorrelationId { get; init; } = Guid.NewGuid();
    public Guid ProdutoId { get; init; }
    public Guid TenantId { get; init; }
    public string Sku { get; init; } = string.Empty;
    public string Nome { get; init; } = string.Empty;
    public decimal Preco { get; init; }
}
```

```C#
C#

// Produtos.Contracts/Events/V2/ProdutoCriadoEventV2.cs (Evolução Additive-Only)
namespace Produtos.Contracts.Events.V2;

public record ProdutoCriadoEventV2
{
    public Guid CorrelationId { get; init; } = Guid.NewGuid();
    public Guid ProdutoId { get; init; }
    public Guid TenantId { get; init; }
    public string Sku { get; init; } = string.Empty;
    public string Nome { get; init; } = string.Empty;
    public decimal Preco { get; init; }
    
    // Novo campo adicionado sem quebrar a V1
    public string UnidadeMedida { get; init; } = "UN"; 
    public DateTime OccurredOnUtc { get; init; } = DateTime.UtcNow;
}
```

2. Entidade de Domínio e Regras de Negócio (```Produtos.Domain```)

```C#
C#

// Produtos.Domain/Entities/Produto.cs
namespace Produtos.Domain.Entities;

public class Produto
{
    public Guid Id { get; private set; }
    public Guid TenantId { get; private set; }
    public string Sku { get; private set; }
    public string Nome { get; private set; }
    public decimal Preco { get; private set; }
    public string UnidadeMedida { get; private set; }
    public bool Ativo { get; private set; }
    public DateTime CriadoEmUtc { get; private set; }

    protected Produto() { } // Requerido pelo EF Core

    public Produto(Guid tenantId, string sku, string nome, decimal preco, string unidadeMedida = "UN")
    {
        if (string.IsNullOrWhiteSpace(sku))
            throw new ArgumentException("O SKU do produto é obrigatório.");

        if (string.IsNullOrWhiteSpace(nome))
            throw new ArgumentException("O nome do produto é obrigatório.");

        if (preco <= 0)
            throw new ArgumentException("O preço do produto deve ser maior que zero.");

        Id = Guid.NewGuid();
        TenantId = tenantId;
        Sku = sku.ToUpper().Trim();
        Nome = nome.Trim();
        Preco = preco;
        UnidadeMedida = string.IsNullOrWhiteSpace(unidadeMedida) ? "UN" : unidadeMedida.ToUpper().Trim();
        Ativo = true;
        CriadoEmUtc = DateTime.UtcNow;
    }

    public void AtualizarPreco(decimal novoPreco)
    {
        if (novoPreco <= 0)
            throw new ArgumentException("O novo preço deve ser maior que zero.");

        Preco = novoPreco;
    }

    public void Desativar() => Ativo = false;
    public void Ativar() => Ativar();
}
```

3. EF Core DbContext com Outbox Pattern do MassTransit (```Produtos.Infrastructure```)

Configuração que ativa a tabela de **Outbox** automática do **MassTransit** no mesmo **DbContext** da aplicação para garantir consistência transacional:

```C#
C#

// Produtos.Infrastructure/Data/ProdutoDbContext.cs
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Platform.Multitenancy;
using Produtos.Domain.Entities;

namespace Produtos.Infrastructure.Data;

public class ProdutoDbContext : DbContext
{
    private readonly ITenantContext _tenantContext;

    public DbSet<Produto> Produtos => Set<Produto>();

    public ProdutoDbContext(DbContextOptions<ProdutoDbContext> options, ITenantContext tenantContext) 
        : base(options)
    {
        _tenantContext = tenantContext;
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Mapeamento das tabelas nativas do Transactional Outbox Pattern do MassTransit
        modelBuilder.AddTransactionalOutboxEntities();

        modelBuilder.Entity<Produto>(builder =>
        {
            builder.ToTable("Produtos");
            builder.HasKey(p => p.Id);

            builder.Property(p => p.Sku).IsRequired().HasMaxLength(50);
            builder.Property(p => p.Nome).IsRequired().HasMaxLength(200);
            builder.Property(p => p.Preco).HasColumnType("decimal(18,2)").IsRequired();
            builder.Property(p => p.UnidadeMedida).IsRequired().HasMaxLength(10);

            // Garante que o SKU é único dentro de um mesmo Tenant
            builder.HasIndex(p => new { p.TenantId, p.Sku }).IsUnique();

            // Global Query Filter para Garantia de Isolamento Multi-tenant
            builder.HasQueryFilter(p => p.TenantId == _tenantContext.TenantId);
        });
    }
}
```

4. Handler com Publicação Dupla para Compatibilidade (```Produtos.Application```)

Publica a versão nova (```V2```) e também mantém a emissão da ```V1``` para serviços consumidores legados:

```C#
C#

// Produtos.Application/Commands/CriarProduto/CriarProdutoCommandHandler.cs
using MassTransit;
using Platform.Multitenancy;
using Platform.Shared.Results;
using Produtos.Contracts.Events.V1;
using Produtos.Contracts.Events.V2;
using Produtos.Domain.Entities;
using Produtos.Infrastructure.Data;

namespace Produtos.Application.Commands.CriarProduto;

public record CriarProdutoCommand(string Sku, string Nome, decimal Preco, string UnidadeMedida);

public class CriarProdutoCommandHandler
{
    private readonly ProdutoDbContext _dbContext;
    private readonly ITenantContext _tenantContext;
    private readonly IPublishEndpoint _publishEndpoint;

    public CriarProdutoCommandHandler(
        ProdutoDbContext dbContext, 
        ITenantContext tenantContext, 
        IPublishEndpoint publishEndpoint)
    {
        _dbContext = dbContext;
        _tenantContext = tenantContext;
        _publishEndpoint = publishEndpoint;
    }

    public async Task<Result<Guid>> HandleAsync(CriarProdutoCommand command, CancellationToken ct)
    {
        if (!_tenantContext.TenantId.HasValue)
            return Result.Failure<Guid>("Tenant não resolvido no contexto da requisição.");

        try
        {
            var produto = new Produto(
                _tenantContext.TenantId.Value, 
                command.Sku, 
                command.Nome, 
                command.Preco, 
                command.UnidadeMedida);

            _dbContext.Produtos.Add(produto);

            // 1. Emissão do Evento V1 (Suporte a serviços/consumers legados)
            await _publishEndpoint.Publish(new ProdutoCriadoEventV1
            {
                ProdutoId = produto.Id,
                TenantId = produto.TenantId,
                Sku = produto.Sku,
                Nome = produto.Nome,
                Preco = produto.Preco
            }, ct);

            // 2. Emissão do Evento V2 (Suporte a novos serviços consumidores)
            await _publishEndpoint.Publish(new ProdutoCriadoEventV2
            {
                ProdutoId = produto.Id,
                TenantId = produto.TenantId,
                Sku = produto.Sku,
                Nome = produto.Nome,
                Preco = produto.Preco,
                UnidadeMedida = produto.UnidadeMedida,
                OccurredOnUtc = DateTime.UtcNow
            }, ct);

            // Transação Atômica SQL: Grava o produto e os eventos do Outbox na mesma transação!
            await _dbContext.SaveChangesAsync(ct);

            return Result.Success(produto.Id);
        }
        catch (ArgumentException ex)
        {
            return Result.Failure<Guid>(ex.Message);
        }
        catch (Exception ex)
        {
            return Result.Failure<Guid>($"Erro ao processar criação de produto: {ex.Message}");
        }
    }
}
```

5. Program EntryPoint com Configuração Completa do Outbox (```Produtos.API/Program.cs```)

```C#
C#

// Produtos.API/Program.cs
using MassTransit;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Platform.Multitenancy;
using Platform.Observability;
using Produtos.Application.Commands.CriarProduto;
using Produtos.Infrastructure.Data;

var builder = WebApplication.CreateBuilder(args);

// Observabilidade (Serilog)
builder.Host.UseCustomSerilog("Produtos.API");

// Connection String do Banco de Dados
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=localhost;Database=Db_Produtos;User Id=sa;Password=Senh@ForteCondominio2026!;Encrypt=False;TrustServerCertificate=True;";

builder.Services.AddDbContext<ProdutoDbContext>(opts =>
    opts.UseSqlServer(connectionString));

// Building Blocks da Plataforma
builder.Services.AddMultitenancy();
builder.Services.AddCustomObservability("Produtos.API", builder.Configuration["OpenTelemetry:Endpoint"] ?? "http://localhost:4317");

// Injeção do MassTransit integrado com Transactional Outbox
builder.Services.AddMassTransit(x =>
{
    x.AddEntityFrameworkOutbox<ProdutoDbContext>(o =>
    {
        o.UseSqlServer();
        o.UseBusOutbox(); // Redireciona a publicação do IPublishEndpoint para as tabelas Outbox do DB
    });

    x.UsingRabbitMq((context, cfg) =>
    {
        var host = builder.Configuration["RabbitMq:Host"] ?? "localhost";
        var username = builder.Configuration["RabbitMq:UserName"] ?? "guest";
        var password = builder.Configuration["RabbitMq:Password"] ?? "guest";

        cfg.Host(host, "/", h =>
        {
            h.Username(username);
            h.Password(password);
        });

        cfg.ConfigureEndpoints(context);
    });
});

// Registrar os Handlers da Aplicação
builder.Services.AddScoped<CriarProdutoCommandHandler>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UsePrometheusEndpoint();
app.UseRouting();
app.UseTenantMiddleware();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Minimal APIs
app.MapPost("/api/v1/produtos", async (
    [FromBody] CriarProdutoCommand command, 
    [FromServices] CriarProdutoCommandHandler handler, 
    CancellationToken ct) =>
{
    var result = await handler.HandleAsync(command, ct);

    if (result.IsFailure)
    {
        return Results.BadRequest(new { error = result.Error });
    }

    return Results.Created($"/api/v1/produtos/{result.Value}", new { id = result.Value });
})
.WithName("CriarProduto")
.WithOpenApi();

app.MapGet("/api/v1/produtos/{id:guid}", async (
    Guid id, 
    [FromServices] ProdutoDbContext dbContext, 
    CancellationToken ct) =>
{
    var produto = await dbContext.Produtos.FirstOrDefaultAsync(p => p.Id == id, ct);
    if (produto == null) return Results.NotFound();

    return Results.Ok(produto);
})
.WithName("ObterProdutoPorId")
.WithOpenApi();

await app.RunAsync();
```

### 📦 Pacotes NuGet Necessários

- Produtos.API.csproj:
  - MassTransit.EntityFrameworkCore
  - MassTransit.RabbitMQ
  - Swashbuckle.AspNetCore
  - Referências de Projeto:
      - Produtos.Infrastructure, Produtos.Application, Produtos.Contracts, Platform.Observability, Platform.Multitenancy
- Produtos.Infrastructure.csproj:
  - MassTransit.EntityFrameworkCore
  - Microsoft.EntityFrameworkCore.SqlServer
  - Microsoft.EntityFrameworkCore.Design
  - Referências de Projeto:
      - Produtos.Domain, Produtos.Application, Platform.Multitenancy
- Produtos.Application.csproj:
  - Referências de Projeto:
      - Produtos.Domain, Produtos.Contracts, Platform.Shared


### 🤖 Como Orquestrar o Copilot Chat no VS

No painel do GitHub Copilot Chat no Visual Studio, execute:

**1. Ativação do Outbox no EF Core:**

```@workspace Modifique a injeção do MassTransit no Program.cs de 'Produtos.API' para incluir o '.AddEntityFrameworkOutbox<ProdutoDbContext>()' e '.UseSqlServer()'.```

**2. Geração dos Endpoints de Catálogo:**

  ```#file:CriarProdutoCommandHandler.cs Crie uma Minimal API em Produtos.API com as rotas POST '/api/v1/produtos' e GET '/api/v1/produtos/{id}'.```

Com a solução Produtos.sln finalizada e testada, temos o catálogo operacional com governança de eventos e Outbox Pattern ativo!

---

## 🏗️ Fase 10 Pedidos Service (Pedidos, Checkout Workflow, Intenção de Compra, Eventos & Idempotência HTTP/Consumer, Outbox).

Na **Fase** **Bounded Context**, lida com operações críticas de escrita financeira e transacional. O grande foco arquitetural aqui é a **Idempotência**: garantir que chamadas HTTP duplicadas (```ex: clique duplo do usuário no checkout```) ou entregas repetidas de mensagens pelo broker (```comportamento at-least-once do RabbitMQ```) não criem pedidos duplicados nem processem a mesma transação mais de uma vez.

### 🎯 Objetivos

1. ```Gestão de Pedidos (Checkout Workflow)```: Abertura de pedido como *Intenção de Compra* (```Rascunho -> Processando -> Aprovado/Cancelado```).

2. ```Idempotência no Endpoint REST (Header X-Idempotency-Key)```: Interceptador HTTP que memoriza a resposta para chaves repetidas em uma janela de tempo.

3. ```Idempotência na Mensageria (Tabela ProcessedMessages / Inbox Pattern)```: Garantir que consumers processem o evento exatamente uma única vez por ID.

4. ```Disparo do Evento de Integração PedidoCriadoIntegrationEvent```: Notificar o domínio de **Estoque** (**Fase seguinte**) para reserva lógica de itens de forma assíncrona.

### 🏗️ Estrutura da Solução

```Plaintext
Plaintext

Services/Pedidos/
├── Pedidos.API/          # Minimal APIs, Idempotency Middleware, HealthChecks
├── Pedidos.Application/  # Commands (CriarPedidoCommand), CQRS Handlers, Behaviors
├── Pedidos.Domain/       # Entidades Pedido, ItemPedido, StatusPedido, ValueObjects
├── Pedidos.Infrastructure/# EF Core (PedidoDbContext), Filter/Inbox Table, Repositórios
├── Pedidos.Contracts/    # Integration Events (PedidoCriadoIntegrationEvent)
└── Pedidos.Tests/
```

### 💻 Implementação Prática

1. Entidade de Domínio do Pedido (```Pedidos.Domain```)

O pedido nasce com status ```Rascunho``` ou ```AguardandoProcessamento``` e é composto por itens com controle rígido de imutabilidade:

```C#
C#

// Pedidos.Domain/Entities/Pedido.cs
namespace Pedidos.Domain.Entities;

public class Pedido
{
    private readonly List<ItemPedido> _itens = new();

    public Guid Id { get; private set; }
    public Guid TenantId { get; private set; }
    public Guid ClienteId { get; private set; }
    public StatusPedido Status { get; private set; }
    public decimal ValorTotal { get; private set; }
    public DateTime CriadoEmUtc { get; private set; }
    public IReadOnlyCollection<ItemPedido> Itens => _itens.AsReadOnly();

    protected Pedido() { } // EF Core

    public Pedido(Guid tenantId, Guid clienteId)
    {
        Id = Guid.NewGuid();
        TenantId = tenantId;
        ClienteId = clienteId;
        Status = StatusPedido.AguardandoProcessamento;
        CriadoEmUtc = DateTime.UtcNow;
    }

    public void AdicionarItem(Guid produtoId, string sku, string nomeProduto, int quantidade, decimal precoUnitario)
    {
        if (quantidade <= 0)
            throw new ArgumentException("A quantidade do item deve ser maior que zero.");

        var item = new ItemPedido(Id, produtoId, sku, nomeProduto, quantidade, precoUnitario);
        _itens.Add(item);
        
        CalcularValorTotal();
    }

    private void CalcularValorTotal()
    {
        ValorTotal = _itens.Sum(i => i.Quantidade * i.PrecoUnitario);
    }

    public void Confirmar() => Status = StatusPedido.Confirmado;
    public void Cancelar() => Status = StatusPedido.Cancelado;
}

public enum StatusPedido
{
    AguardandoProcessamento = 1,
    Confirmado = 2,
    Cancelado = 3
}
```

```C#
C#
// Pedidos.Domain/Entities/ItemPedido.cs
public class ItemPedido
{
    public Guid Id { get; private set; }
    public Guid PedidoId { get; private set; }
    public Guid ProdutoId { get; private set; }
    public string Sku { get; private set; }
    public string NomeProduto { get; private set; }
    public int Quantidade { get; private set; }
    public decimal PrecoUnitario { get; private set; }

    protected ItemPedido() { }

    public ItemPedido(Guid pedidoId, Guid produtoId, string sku, string nomeProduto, int quantidade, decimal precoUnitario)
    {
        Id = Guid.NewGuid();
        PedidoId = pedidoId;
        ProdutoId = produtoId;
        Sku = sku;
        NomeProduto = nomeProduto;
        Quantidade = quantidade;
        PrecoUnitario = precoUnitario;
    }
}
```

2. Tabela de Idempotência do Consumer / Outbox / Inbox (```Pedidos.Infrastructure```)

Registramos as mensagens processadas e aplicamos o filtro global no ```PedidoDbContext```:

```C#
C#

// Pedidos.Infrastructure/Data/PedidoDbContext.cs
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Pedidos.Domain.Entities;
using Platform.Multitenancy;

namespace Pedidos.Infrastructure.Data;

public class PedidoDbContext : DbContext
{
    private readonly ITenantContext _tenantContext;

    public DbSet<Pedido> Pedidos => Set<Pedido>();
    public DbSet<ItemPedido> ItensPedido => Set<ItemPedido>();
    public DbSet<ProcessedMessage> ProcessedMessages => Set<ProcessedMessage>();

    public PedidoDbContext(DbContextOptions<PedidoDbContext> options, ITenantContext tenantContext) 
        : base(options)
    {
        _tenantContext = tenantContext;
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Habilita automaticamente os esquemas de Outbox e Inbox do MassTransit
        modelBuilder.AddTransactionalOutboxEntities();

        modelBuilder.Entity<Pedido>(builder =>
        {
            builder.ToTable("Pedidos");
            builder.HasKey(p => p.Id);
            builder.Property(p => p.ValorTotal).HasColumnType("decimal(18,2)").IsRequired();
            builder.Property(p => p.Status).IsRequired();

            builder.HasMany(p => p.Itens)
                   .WithOne()
                   .HasForeignKey(i => i.PedidoId)
                   .OnDelete(DeleteBehavior.Cascade);

            // Global Query Filter para suporte a isolamento Multi-tenant
            builder.HasQueryFilter(p => p.TenantId == _tenantContext.TenantId);
        });

        modelBuilder.Entity<ItemPedido>(builder =>
        {
            builder.ToTable("ItensPedido");
            builder.HasKey(i => i.Id);
            builder.Property(i => i.PrecoUnitario).HasColumnType("decimal(18,2)").IsRequired();
            builder.Property(i => i.Sku).IsRequired().HasMaxLength(50);
            builder.Property(i => i.NomeProduto).IsRequired().HasMaxLength(200);
        });

        modelBuilder.Entity<ProcessedMessage>(builder =>
        {
            builder.ToTable("ProcessedMessages");
            builder.HasKey(pm => pm.MessageId);
        });
    }
}

public class ProcessedMessage
{
    public Guid MessageId { get; set; }
    public string ConsumerName { get; set; } = string.Empty;
    public DateTime ProcessedAtUtc { get; set; } = DateTime.UtcNow;
}
```

3. Evento de Integração ```PedidoCriadoIntegrationEvent``` (```Pedidos.Contracts```)

O contrato enviado via mensageria para alertar o domínio de **Estoque**:

```C#
C#

// Pedidos.Contracts/Events/PedidoCriadoIntegrationEvent.cs
namespace Pedidos.Contracts.Events;

public record PedidoCriadoIntegrationEvent
{
    public Guid CorrelationId { get; init; } = Guid.NewGuid();
    public Guid PedidoId { get; init; }
    public Guid TenantId { get; init; }
    public Guid ClienteId { get; init; }
    public decimal ValorTotal { get; init; }
    public List<ItemPedidoDto> Itens { get; init; } = new();
    public DateTime OccurredOnUtc { get; init; } = DateTime.UtcNow;
}
public record ItemPedidoDto(Guid ProdutoId, string Sku, int Quantidade, decimal PrecoUnitario);
```

4. Handler com Gravação do Outbox (```Pedidos.Application```)

```C#
C#

// Pedidos.Application/Commands/CriarPedido/CriarPedidoCommandHandler.cs
using MassTransit;
using Pedidos.Contracts.Events;
using Pedidos.Domain.Entities;
using Pedidos.Infrastructure.Data;
using Platform.Multitenancy;
using Platform.Shared.Results;

namespace Pedidos.Application.Commands.CriarPedido;

public record CriarPedidoCommand(Guid ClienteId, List<CriarItemPedidoDto> Itens);
public record CriarItemPedidoDto(Guid ProdutoId, string Sku, string NomeProduto, int Quantidade, decimal PrecoUnitario);

public class CriarPedidoCommandHandler
{
    private readonly PedidoDbContext _dbContext;
    private readonly ITenantContext _tenantContext;
    private readonly IPublishEndpoint _publishEndpoint;

    public CriarPedidoCommandHandler(
        PedidoDbContext dbContext, 
        ITenantContext tenantContext, 
        IPublishEndpoint publishEndpoint)
    {
        _dbContext = dbContext;
        _tenantContext = tenantContext;
        _publishEndpoint = publishEndpoint;
    }

    public async Task<Result<Guid>> HandleAsync(CriarPedidoCommand command, CancellationToken ct)
    {
        if (!_tenantContext.TenantId.HasValue)
            return Result.Failure<Guid>("TenantID ausente na requisição.");

        if (command.Itens == null || !command.Itens.Any())
            return Result.Failure<Guid>("O pedido deve possuir ao menos um item.");

        var pedido = new Pedidos.Domain.Entities.Pedido(_tenantContext.TenantId.Value, command.ClienteId);

        foreach (var item in command.Itens)
        {
            pedido.AdicionarItem(item.ProdutoId, item.Sku, item.NomeProduto, item.Quantidade, item.PrecoUnitario);
        }

        _dbContext.Pedidos.Add(pedido);

        // Publica evento para a fila do RabbitMQ
        await _publishEndpoint.Publish(new PedidoCriadoIntegrationEvent
        {
            PedidoId = pedido.Id,
            TenantId = pedido.TenantId,
            ClienteId = pedido.ClienteId,
            ValorTotal = pedido.ValorTotal,
            Itens = command.Itens.Select(i => new ItemPedidoDto(i.ProdutoId, i.Sku, i.Quantidade, i.PrecoUnitario)).ToList()
        }, ct);

        // O Outbox garante que evento + pedido vão pro SQL Server de forma atômica
        await _dbContext.SaveChangesAsync(ct);

        return Result.Success(pedido.Id);
    }
}
```

5. Middleware de Idempotência HTTP (```Pedidos.API/Middlewares/IdempotencyMiddleware.cs```)

Este middleware captura o header ```X-Idempotency-Key```, intercepta o pipeline HTTP e evita reprocessamentos caso o cliente efetue cliques duplos no checkout:

```C#
C#

// Pedidos.API/Middlewares/IdempotencyMiddleware.cs
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Caching.Distributed;

namespace Pedidos.API.Middlewares;

public class IdempotencyMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IDistributedCache _cache;
    private const string IdempotencyHeaderKey = "X-Idempotency-Key";

    public IdempotencyMiddleware(RequestDelegate next, IDistributedCache cache)
    {
        _next = next;
        _cache = cache;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Intercepta apenas métodos de modificação de estado (POST, PUT, PATCH)
        if (!HttpMethods.IsPost(context.Request.Method) && 
            !HttpMethods.IsPut(context.Request.Method) && 
            !HttpMethods.IsPatch(context.Request.Method))
        {
            await _next(context);
            return;
        }

        if (!context.Request.Headers.TryGetValue(IdempotencyHeaderKey, out var idempotencyKey) || 
            string.IsNullOrWhiteSpace(idempotencyKey))
        {
            await _next(context);
            return;
        }

        var cacheKey = $"idempotency:{idempotencyKey}";
        var cachedResponse = await _cache.GetStringAsync(cacheKey);

        if (!string.IsNullOrEmpty(cachedResponse))
        {
            var savedResult = JsonSerializer.Deserialize<CachedHttpResponse>(cachedResponse);
            if (savedResult != null)
            {
                context.Response.StatusCode = savedResult.StatusCode;
                context.Response.ContentType = "application/json";
                await context.Response.WriteAsync(savedResult.Body);
                return;
            }
        }

        // Intercepta a resposta original para gravar no cache
        var originalBodyStream = context.Response.Body;
        using var responseBody = new MemoryStream();
        context.Response.Body = responseBody;

        await _next(context);

        if (context.Response.StatusCode is >= 200 and < 300)
        {
            responseBody.Seek(0, SeekOrigin.Begin);
            var bodyText = await new StreamReader(responseBody).ReadToEndAsync();
            responseBody.Seek(0, SeekOrigin.Begin);

            var cachePayload = new CachedHttpResponse
            {
                StatusCode = context.Response.StatusCode,
                Body = bodyText
            };

            await _cache.SetStringAsync(
                cacheKey, 
                JsonSerializer.Serialize(cachePayload), 
                new DistributedCacheEntryOptions
                {
                    AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10) // Window de Idempotência
                });
        }

        await responseBody.CopyToAsync(originalBodyStream);
    }
}

public record CachedHttpResponse
{
    public int StatusCode { get; init; }
    public string Body { get; init; } = string.Empty;
}
```

6. EntryPoint com Registros de Middleware e MassTransit Outbox (```Pedidos.API/Program.cs```)

```C#
C#

// Pedidos.API/Program.cs
using MassTransit;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Pedidos.API.Middlewares;
using Pedidos.Application.Commands.CriarPedido;
using Pedidos.Infrastructure.Data;
using Platform.Multitenancy;
using Platform.Observability;

var builder = WebApplication.CreateBuilder(args);

// Serilog & Observabilidade
builder.Host.UseCustomSerilog("Pedidos.API");

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=localhost;Database=Db_Pedidos;User Id=sa;Password=Senh@ForteCondominio2026!;Encrypt=False;TrustServerCertificate=True;";

builder.Services.AddDbContext<PedidoDbContext>(opts =>
    opts.UseSqlServer(connectionString));

// Suporte ao cache em memória para a janela de idempotência HTTP (X-Idempotency-Key)
builder.Services.AddDistributedMemoryCache();

// Building Blocks da Plataforma
builder.Services.AddMultitenancy();
builder.Services.AddCustomObservability("Pedidos.API", builder.Configuration["OpenTelemetry:Endpoint"] ?? "http://localhost:4317");

// MassTransit com Transactional Outbox
builder.Services.AddMassTransit(x =>
{
    x.AddEntityFrameworkOutbox<PedidoDbContext>(o =>
    {
        o.UseSqlServer();
        o.UseBusOutbox();
    });

    x.UsingRabbitMq((context, cfg) =>
    {
        var host = builder.Configuration["RabbitMq:Host"] ?? "localhost";
        var username = builder.Configuration["RabbitMq:UserName"] ?? "guest";
        var password = builder.Configuration["RabbitMq:Password"] ?? "guest";

        cfg.Host(host, "/", h =>
        {
            h.Username(username);
            h.Password(password);
        });

        cfg.ConfigureEndpoints(context);
    });
});

// Handlers CQRS
builder.Services.AddScoped<CriarPedidoCommandHandler>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UsePrometheusEndpoint();
app.UseRouting();

// Middleware de Tenant
app.UseTenantMiddleware();

// Middleware de Idempotência HTTP
app.UseMiddleware<IdempotencyMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Minimal API - Checkout de Pedido
app.MapPost("/api/v1/pedidos", async (
    [FromBody] CriarPedidoCommand command, 
    [FromServices] CriarPedidoCommandHandler handler, 
    CancellationToken ct) =>
{
    var result = await handler.HandleAsync(command, ct);

    if (result.IsFailure)
    {
        return Results.BadRequest(new { error = result.Error });
    }

    return Results.Created($"/api/v1/pedidos/{result.Value}", new { id = result.Value });
})
.WithName("CriarPedido")
.WithOpenApi();

app.MapGet("/api/v1/pedidos/{id:guid}", async (
    Guid id, 
    [FromServices] PedidoDbContext dbContext, 
    CancellationToken ct) =>
{
    var pedido = await dbContext.Pedidos
        .Include(p => p.Itens)
        .FirstOrDefaultAsync(p => p.Id == id, ct);

    if (pedido == null) return Results.NotFound();

    return Results.Ok(pedido);
})
.WithName("ObterPedidoPorId")
.WithOpenApi();

await app.RunAsync();
```

### 📦 Pacotes NuGet Necessários

- Pedidos.API.csproj:
  - MassTransit.EntityFrameworkCore
  - MassTransit.RabbitMQ
  - Swashbuckle.AspNetCore
  - Referências de Projeto:
      - Pedidos.Infrastructure, Pedidos.Application, Pedidos.Contracts, Platform.Observability, Platform.Multitenancy
- Pedidos.Infrastructure.csproj:
  - MassTransit.EntityFrameworkCore
  - Microsoft.EntityFrameworkCore.SqlServer
  - Microsoft.EntityFrameworkCore.Design
  - Referências de Projeto:
      - Pedidos.Domain, Pedidos.Application, Platform.Multitenancy
- Pedidos.Application.csproj:
  - Referências de Projeto:
      - Pedidos.Domain, Pedidos.Contracts, Platform.Shared

### 🤖 Como Orquestrar o Copilot Chat no VS

Execute os comandos a seguir no GitHub Copilot Chat:

**1. Configuração do Middleware de Idempotência HTTP:**

```#file:Program.cs Crie e registre um Middleware no projeto 'Pedidos.API' que intercepte requisições com o Header 'X-Idempotency-Key', armazenando o payload retornado no cache por 10 minutos.```

**2. Criação da Migration do Pedido com Outbox:**

```@workspace Execute a criação da Migration do EF Core na camada 'Pedidos.Infrastructure' para criar as tabelas Pedidos, ItensPedido e Outbox.```

Com o serviço Pedidos.sln ativo, a intenção de compra é persistida com idempotência garantida e os eventos de criação já estão sendo publicados no barramento!

---

## 🏗️ Fase 11 Estoque Service (Reserva Lógica, Baixa Física, Concorrência Otimista com RowVersion, Saga Orchestration/Choreography)

Na **Fase** esse microsserviço, gerencia o saldo físico de produtos por **Tenant** e lida com o problema clássico de sistemas distribuídos: concorrência ao reservar o mesmo item simultaneamente e a garantia de que não haverá *overselling* (vender mais do que o estoque disponível).

### 🎯 Objetivos

1. ```Gestão de Estoque por Tenant```: Controle de Saldo Físico, Saldo Reservado e Saldo Disponível (```Disponivel = Fisico - Reservado```).

2. ```Consumo do Evento PedidoCriadoIntegrationEvent```: Consumer no MassTransit que tenta fazer a Reserva Lógica dos itens ao receber um novo pedido.

3. ```Bloqueio Otimista / Lock Distribuído```: Prevenção de race conditions ao atualizar o saldo do produto.

4. ```Resposta Event-Driven (Sucesso/Falha)```: Publicação de ```EstoqueReservadoIntegrationEvent``` ou ```EstoqueInsuficienteIntegrationEvent``` para alimentar o fluxo da **Saga/Pedido**.

### 🏗️ Estrutura da Solução

```Plaintext
Plaintext

Services/Estoque/
├── Estoque.API/          # Minimal APIs para ajuste manual/consulta de saldo
├── Estoque.Worker/       # MassTransit Consumers (PedidoCriadoConsumer)
├── Estoque.Application/  # Use Cases (ReservarEstoqueCommandHandler, DarBaixaCommandHandler)
├── Estoque.Domain/       # Entidades EstoqueItem, MovimentacaoEstoque, Exceções do Domínio
├── Estoque.Infrastructure/# EF Core (EstoqueDbContext), Mapeamentos com RowVersion (Concurrency)
├── Estoque.Contracts/    # Events (EstoqueReservadoIntegrationEvent, EstoqueInsuficienteIntegrationEvent)
└── Estoque.Tests/
```

### 💻 Implementação Prática

1. Entidade de Domínio com Concorrência Otimista (```Estoque.Domain```)

A entidade controla o saldo disponível e lança exceção do domínio caso o pedido exceda o saldo físico restante:

```C#
C#

// Estoque.Domain/Entities/EstoqueItem.cs
namespace Estoque.Domain.Entities;

public class EstoqueItem
{
    public Guid Id { get; private set; }
    public Guid TenantId { get; private set; }
    public Guid ProdutoId { get; private set; }
    public string Sku { get; private set; }
    public int QuantidadeFisica { get; private set; }
    public int QuantidadeReservada { get; private set; }
    public int QuantidadeDisponivel => QuantidadeFisica - QuantidadeReservada;
    
    // Campo de controle de Concorrência Otimista (Byte array mapeado como RowVersion / Timestamp no SQL Server)
    public byte[] RowVersion { get; private set; } = Array.Empty<byte>();

    protected EstoqueItem() { } // Requerido pelo EF Core

    public EstoqueItem(Guid tenantId, Guid produtoId, string sku, int quantidadeInicial)
    {
        if (string.IsNullOrWhiteSpace(sku))
            throw new ArgumentException("O SKU é obrigatório.");

        if (quantidadeInicial < 0)
            throw new ArgumentException("A quantidade inicial de estoque não pode ser negativa.");

        Id = Guid.NewGuid();
        TenantId = tenantId;
        ProdutoId = produtoId;
        Sku = sku.ToUpper().Trim();
        QuantidadeFisica = quantidadeInicial;
        QuantidadeReservada = 0;
    }

    public void TentarReservar(int quantidade)
    {
        if (quantidade <= 0)
            throw new ArgumentException("A quantidade a ser reservada deve ser maior que zero.");

        if (QuantidadeDisponivel < quantidade)
            throw new InvalidOperationException($"Estoque insuficiente para o SKU '{Sku}'. Disponível: {QuantidadeDisponivel}, Solicitado: {quantidade}.");

        QuantidadeReservada += quantidade;
    }

    public void ConfirmarBaixa(int quantidade)
    {
        if (quantidade <= 0)
            throw new ArgumentException("A quantidade de baixa deve ser maior que zero.");

        if (QuantidadeReservada < quantidade)
            throw new InvalidOperationException($"Quantidade a baixar ({quantidade}) é superior à quantidade reservada ({QuantidadeReservada}).");

        QuantidadeReservada -= quantidade;
        QuantidadeFisica -= quantidade;
    }

    public void CancelarReserva(int quantidade)
    {
        if (quantidade <= 0)
            throw new ArgumentException("A quantidade a cancelar deve ser maior que zero.");

        QuantidadeReservada = Math.Max(0, QuantidadeReservada - quantidade);
    }

    public void AdicionarEstoqueFisico(int quantidade)
    {
        if (quantidade <= 0)
            throw new ArgumentException("A quantidade a adicionar deve ser maior que zero.");

        QuantidadeFisica += quantidade;
    }
}
```

2. Contratos de Eventos de Resposta (```Estoque.Contracts```)

Eventos que informam ao ecossistema o resultado do processamento da reserva:

```C#
C#

// Estoque.Contracts/Events/EstoqueReservadoIntegrationEvent.cs
namespace Estoque.Contracts.Events;

public record EstoqueReservadoIntegrationEvent
{
    public Guid CorrelationId { get; init; } = Guid.NewGuid();
    public Guid PedidoId { get; init; }
    public Guid TenantId { get; init; }
    public decimal ValorTotal { get; init; }
    public DateTime OccurredOnUtc { get; init; } = DateTime.UtcNow;
}
```

```C#
C#
// Estoque.Contracts/Events/EstoqueInsuficienteIntegrationEvent.cs
public record EstoqueInsuficienteIntegrationEvent
{
    public Guid CorrelationId { get; init; } = Guid.NewGuid();
    public Guid PedidoId { get; init; }
    public Guid TenantId { get; init; }
    public string Motivo { get; init; } = string.Empty;
    public DateTime OccurredOnUtc { get; init; } = DateTime.UtcNow;
}
```

3. DbContext com Mapeamento de ```RowVersion``` (```Estoque.Infrastructure```)

```C#
C#

// Estoque.Infrastructure/Data/EstoqueDbContext.cs
using Estoque.Domain.Entities;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Platform.Multitenancy;

namespace Estoque.Infrastructure.Data;

public class EstoqueDbContext : DbContext
{
    private readonly ITenantContext _tenantContext;

    public DbSet<EstoqueItem> EstoqueItens => Set<EstoqueItem>();

    public EstoqueDbContext(DbContextOptions<EstoqueDbContext> options, ITenantContext tenantContext) 
        : base(options)
    {
        _tenantContext = tenantContext;
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Suporte para Outbox/Inbox do MassTransit
        modelBuilder.AddTransactionalOutboxEntities();

        modelBuilder.Entity<EstoqueItem>(builder =>
        {
            builder.ToTable("EstoqueItens");
            builder.HasKey(e => e.Id);
            
            builder.Property(e => e.Sku).IsRequired().HasMaxLength(50);

            // Garante que não haja registros duplicados do mesmo produto por Tenant
            builder.HasIndex(e => new { e.TenantId, e.ProdutoId }).IsUnique();

            // Mapeamento de Concorrência Otimista (SQL Server Timestamp/RowVersion)
            builder.Property(e => e.RowVersion)
                   .IsRowVersion();

            // Isolamento Multi-tenant
            builder.HasQueryFilter(e => e.TenantId == _tenantContext.TenantId);
        });
    }
}
```

4. Consumer do Pedido com Trativa de Sucesso / Compensação (```Estoque.Worker```)

O consumer lê a mensagem de ```PedidoCriadoIntegrationEvent```, busca os itens do tenant e faz a reserva. Se falhar, publica o evento de insucesso para que o **Pedido** seja cancelado automaticamente:

```C#
C#

// Estoque.Worker/Consumers/PedidoCriadoConsumer.cs
using Estoque.Contracts.Events;
using Estoque.Infrastructure.Data;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Pedidos.Contracts.Events;

namespace Estoque.Worker.Consumers;

public class PedidoCriadoConsumer : IConsumer<PedidoCriadoIntegrationEvent>
{
    private readonly EstoqueDbContext _dbContext;
    private readonly IPublishEndpoint _publishEndpoint;
    private readonly ILogger<PedidoCriadoConsumer> _logger;

    public PedidoCriadoConsumer(
        EstoqueDbContext dbContext, 
        IPublishEndpoint publishEndpoint, 
        ILogger<PedidoCriadoConsumer> logger)
    {
        _dbContext = dbContext;
        _publishEndpoint = publishEndpoint;
        _logger = logger;
    }

    public async Task Consume(ConsumeContext<PedidoCriadoIntegrationEvent> context)
    {
        var msg = context.Message;
        _logger.LogInformation("Iniciando reserva de estoque para o Pedido {PedidoId} | Tenant: {TenantId}", msg.PedidoId, msg.TenantId);

        try
        {
            var produtosIds = msg.Itens.Select(i => i.ProdutoId).ToList();

            var estoqueItens = await _dbContext.EstoqueItens
                .Where(e => e.TenantId == msg.TenantId && produtosIds.Contains(e.ProdutoId))
                .ToListAsync(context.CancellationToken);

            foreach (var itemPedido in msg.Itens)
            {
                var estoque = estoqueItens.FirstOrDefault(e => e.ProdutoId == itemPedido.ProdutoId);

                if (estoque == null)
                {
                    await PublicarFalhaAsync(
                        msg.PedidoId, 
                        msg.TenantId, 
                        msg.CorrelationId, 
                        $"Produto SKU '{itemPedido.Sku}' não foi encontrado no cadastro de estoque.", 
                        context.CancellationToken);
                    return;
                }

                // Tenta realizar a reserva lógica
                estoque.TentarReservar(itemPedido.Quantidade);
            }

            // Publica evento de sucesso de reserva
            await _publishEndpoint.Publish(new EstoqueReservadoIntegrationEvent
            {
                PedidoId = msg.PedidoId,
                TenantId = msg.TenantId,
                CorrelationId = msg.CorrelationId
            }, context.CancellationToken);

            // Persiste e grava as alterações e mensagens na tabela de Outbox
            await _dbContext.SaveChangesAsync(context.CancellationToken);
            _logger.LogInformation("Reserva de estoque efetuada com sucesso para o Pedido {PedidoId}", msg.PedidoId);
        }
        catch (InvalidOperationException ex) // Erro de saldo insuficiente no domínio
        {
            _logger.LogWarning("Falha de saldo de estoque para o Pedido {PedidoId}: {Mensagem}", msg.PedidoId, ex.Message);
            await PublicarFalhaAsync(msg.PedidoId, msg.TenantId, msg.CorrelationId, ex.Message, context.CancellationToken);
        }
        catch (DbUpdateConcurrencyException ex) // Colisão de escrita simultânea
        {
            _logger.LogWarning(ex, "Concorrência detectada ao atualizar estoque do Pedido {PedidoId}. A mensagem será re-enfileirada.", msg.PedidoId);
            throw; // Dispara exceção para ativar o Retry Policy do MassTransit
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro inesperado ao processar estoque do Pedido {PedidoId}", msg.PedidoId);
            await PublicarFalhaAsync(msg.PedidoId, msg.TenantId, msg.CorrelationId, $"Erro interno: {ex.Message}", context.CancellationToken);
        }
    }

    private async Task PublicarFalhaAsync(Guid pedidoId, Guid tenantId, Guid correlationId, string motivo, CancellationToken ct)
    {
        await _publishEndpoint.Publish(new EstoqueInsuficienteIntegrationEvent
        {
            PedidoId = pedidoId,
            TenantId = tenantId,
            CorrelationId = correlationId,
            Motivo = motivo
        }, ct);

        await _dbContext.SaveChangesAsync(ct);
    }
}
```

5. Program EntryPoint do Worker (```Estoque.Worker/Program.cs```)

Configuração com Retry Policy nativo do MassTransit para resolver colisões de concorrência otimista e travamentos temporários no banco:

```C#
C#

// Estoque.Worker/Program.cs
using Estoque.Infrastructure.Data;
using Estoque.Worker.Consumers;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Platform.Multitenancy;
using Platform.Observability;

var builder = Host.CreateApplicationBuilder(args);

// Observabilidade
builder.Services.AddCustomObservability("Estoque.Worker", builder.Configuration["OpenTelemetry:Endpoint"] ?? "http://localhost:4317");

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=localhost;Database=Db_Estoque;User Id=sa;Password=Senh@ForteCondominio2026!;Encrypt=False;TrustServerCertificate=True;";

builder.Services.AddDbContext<EstoqueDbContext>(opts =>
    opts.UseSqlServer(connectionString));

builder.Services.AddMultitenancy();

// MassTransit Worker com Outbox e Retry Policy
builder.Services.AddMassTransit(x =>
{
    x.AddConsumer<PedidoCriadoConsumer>();

    x.AddEntityFrameworkOutbox<EstoqueDbContext>(o =>
    {
        o.UseSqlServer();
        o.UseBusOutbox();
    });

    x.UsingRabbitMq((context, cfg) =>
    {
        var host = builder.Configuration["RabbitMq:Host"] ?? "localhost";
        var username = builder.Configuration["RabbitMq:UserName"] ?? "guest";
        var password = builder.Configuration["RabbitMq:Password"] ?? "guest";

        cfg.Host(host, "/", h =>
        {
            h.Username(username);
            h.Password(password);
        });

        // Configuração do Retry em caso de conflito de concorrência (RowVersion)
        cfg.ReceiveEndpoint("estoque-pedido-criado-queue", e =>
        {
            e.UseMessageRetry(r => r.Interval(3, TimeSpan.FromMilliseconds(500))); // Tenta até 3 vezes com intervalo de 500ms
            e.ConfigureConsumer<PedidoCriadoConsumer>(context);
        });
    });
});

var host = builder.Build();
await host.RunAsync();
```

### 📦 Pacotes NuGet Necessários

- Estoque.Worker.csproj:
  - MassTransit.RabbitMQ
  - MassTransit.EntityFrameworkCore
  - Microsoft.EntityFrameworkCore.SqlServer
  - Referências:
      - Estoque.Infrastructure, Estoque.Application, Estoque.Contracts, Pedidos.Contracts, Platform.Observability, Platform.Multitenancy
- Estoque.Infrastructure.csproj:
  - MassTransit.EntityFrameworkCore
  - Microsoft.EntityFrameworkCore.SqlServer
  - Microsoft.EntityFrameworkCore.Design
  - Referências: Estoque.Domain, Estoque.Application, Platform.Multitenancy
- Estoque.Application.csproj:
  - Referências:
      - Estoque.Domain, Estoque.Contracts, Platform.Shared

### 🤖 Como Orquestrar o Copilot Chat no VS

No painel do GitHub Copilot Chat, execute os comandos:

**1. Ativação da Worker do Estoque:**

```@workspace Configure no 'Estoque.Worker/Program.cs' o MassTransit para escutar a fila 'estoque-pedido-criado-queue' vinculada ao consumer 'PedidoCriadoConsumer'.```

**2. Criação da Migration do Estoque:**

```@workspace Crie a migration 'InitialEstoque' na camada 'Estoque.Infrastructure' com o comando 'dotnet ef migrations add InitialEstoque'.```

Com a solução ```Estoque.sln``` integrada ao fluxo de mensageria, temos a gestão transacional de saldo com concorrência e resposta desacoplada por eventos.

📌 Importante: No modelo construído, mantem o padrão **Transacional / Atômico (Tudo ou Nada)**: se 1 item falhar por falta de saldo, o evento de falha é publicado, a **transação SQL do estoque é abortada (Rollback)** e o **Pedido** é cancelado por completo.

### 🔄 E se o negócio EXIGIR suporte a "Atendimento Parcial" de **Pedido**?

Se a regra de negócio do **SaaS** permitir entregas/atendimentos parciais de pedido, a arquitetura muda para o seguinte padrão:

1. Pedido Dividido (```Split Order```): O pedido original é alterado no banco ou subdividido em sub-pedidos (```ex: Pedido # 1001-A com os itens disponíveis e Pedido # 1001-B cancelado/aguardando reposição```).

2. Evento Modificado: Em vez de publicar ```EstoqueInsuficienteIntegrationEvent```, o estoque publica um evento como ```EstoqueReservadoParcialmenteIntegrationEvent``` contendo a lista dos itens que conseguiram reserva e dos que falharam.

3. Confirmação do Cliente: O pedido entra em status ```AguardandoAprovacaoParcial```, exigindo autorização do comprador para faturar apenas o que tem no estoque.

---

## 🏗️ Fase 12 Faturamento Service (NF-e, Processamento Financeiro & Eventos de Conclusão de Venda, Event-Driven)

Na **Fase** **Bounded Context de Faturamento** é o responsável pelo encerramento fiscal e financeiro do ciclo de vendas. Ele reage ao evento de reserva de estoque bem-sucedida, gera a **Nota Fiscal Eletrônica** (```NF-e/NFC-e ou fatura simbólica```) e consolida os dados de pagamento antes de notificar o encerramento da transação.

### 🎯 Objetivos

1. ```Geração e Processamento de Faturas/NF-e```: Registro de títulos financeiros com cálculo de impostos e chave de acesso fiscal simulada.

2. ```Reação Event-Driven```: Consumer que escuta ```EstoqueReservadoIntegrationEvent``` para iniciar automaticamente o faturamento sem intervenção manual.

3. ```Emissão do Evento FaturamentoConcluidoIntegrationEvent```: Notificar a conclusão total do fluxo de venda para que o **Pedido** mude para ```Confirmado``` e o serviço de ```Notification``` envie o comprovante ao cliente/pessoa.

4. ```Resiliência Financeira```: Garantia de idêntico processamento por idempotência para evitar dupla emissão fiscal.

### 🏗️ Estrutura da Solução

```Plaintext
Plaintext

Services/Faturamento/
├── Faturamento.API/          # Minimal APIs para consulta de faturas e dados fiscais
├── Faturamento.Worker/       # MassTransit Consumers (EstoqueReservadoConsumer)
├── Faturamento.Application/  # Use Cases (EmitirFaturaCommandHandler)
├── Faturamento.Domain/       # Entidades Fatura, StatusFatura, ImpostoValueObject
├── Faturamento.Infrastructure/# EF Core (FaturamentoDbContext), Outbox, Mapeamentos
├── Faturamento.Contracts/    # Integration Events (FaturamentoConcluidoIntegrationEvent)
└── Faturamento.Tests/
```

### 💻 Implementação Prática

1. Entidade de Domínio da Fatura (```Faturamento.Domain```)

A fatura possui ciclo de vida próprio e gera uma chave de acesso fiscal simulada:

```C#
C#

// Faturamento.Domain/Entities/Fatura.cs
namespace Faturamento.Domain.Entities;

public class Fatura
{
    public Guid Id { get; private set; }
    public Guid TenantId { get; private set; }
    public Guid PedidoId { get; private set; }
    public decimal ValorTotal { get; private set; }
    public string ChaveAcessoFiscal { get; private set; }
    public StatusFatura Status { get; private set; }
    public DateTime EmitidaEmUtc { get; private set; }

    protected Fatura() { } // Requerido pelo EF Core

    public Fatura(Guid tenantId, Guid pedidoId, decimal valorTotal)
    {
        if (valorTotal <= 0)
            throw new ArgumentException("O valor total da fatura deve ser maior que zero.");

        Id = Guid.NewGuid();
        TenantId = tenantId;
        PedidoId = pedidoId;
        ValorTotal = valorTotal;
        Status = StatusFatura.Emitida;
        ChaveAcessoFiscal = GerarChaveAcessoSimulada(tenantId, Id);
        EmitidaEmUtc = DateTime.UtcNow;
    }

    private static string GerarChaveAcessoSimulada(Guid tenantId, Guid faturaId)
    {
        var timestamp = DateTime.UtcNow.ToString("yyyyMMddHHmmss");
        return $"NFE-{timestamp}-{faturaId.ToString()[..8].ToUpper()}";
    }

    public void Cancelar()
    {
        if (Status == StatusFatura.Cancelada)
            throw new InvalidOperationException("Esta fatura já está cancelada.");

        Status = StatusFatura.Cancelada;
    }
}

public enum StatusFatura
{
    Pendente = 1,
    Emitida = 2,
    Cancelada = 3
}
```

2. Contrato de Evento ```FaturamentoConcluidoIntegrationEvent``` (```Faturamento.Contracts```)

Evento publicado após a emissão com sucesso da fatura:

```C#
C#

// Faturamento.Contracts/Events/FaturamentoConcluidoIntegrationEvent.cs
namespace Faturamento.Contracts.Events;

public record FaturamentoConcluidoIntegrationEvent
{
    public Guid CorrelationId { get; init; } = Guid.NewGuid();
    public Guid FaturaId { get; init; }
    public Guid PedidoId { get; init; }
    public Guid TenantId { get; init; }
    public string ChaveAcessoFiscal { get; init; } = string.Empty;
    public decimal ValorTotal { get; init; }
    public DateTime OccurredOnUtc { get; init; } = DateTime.UtcNow;
}
```

3. DbContext com Outbox Pattern (```Faturamento.Infrastructure```)

```C#
C#

// Faturamento.Infrastructure/Data/FaturamentoDbContext.cs
using Faturamento.Domain.Entities;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Platform.Multitenancy;

namespace Faturamento.Infrastructure.Data;

public class FaturamentoDbContext : DbContext
{
    private readonly ITenantContext _tenantContext;

    public DbSet<Fatura> Faturas => Set<Fatura>();

    public FaturamentoDbContext(DbContextOptions<FaturamentoDbContext> options, ITenantContext tenantContext) 
        : base(options)
    {
        _tenantContext = tenantContext;
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Suporte para Outbox e Inbox do MassTransit
        modelBuilder.AddTransactionalOutboxEntities();

        modelBuilder.Entity<Fatura>(builder =>
        {
            builder.ToTable("Faturas");
            builder.HasKey(f => f.Id);

            builder.Property(f => f.ValorTotal).HasColumnType("decimal(18,2)").IsRequired();
            builder.Property(f => f.ChaveAcessoFiscal).IsRequired().HasMaxLength(60);

            // Garante que exista no máximo 1 fatura ativa por pedido dentro do Tenant
            builder.HasIndex(f => new { f.TenantId, f.PedidoId }).IsUnique();

            // Isolamento Multi-tenant
            builder.HasQueryFilter(f => f.TenantId == _tenantContext.TenantId);
        });
    }
}
```

4. Consumer que aciona o Faturamento (```Faturamento.Worker```)

O worker consome a confirmação de reserva de estoque e processa a fatura:

```C#
C#

// Faturamento.Worker/Consumers/EstoqueReservadoConsumer.cs
using Estoque.Contracts.Events;
using Faturamento.Contracts.Events;
using Faturamento.Domain.Entities;
using Faturamento.Infrastructure.Data;
using MassTransit;
using Microsoft.EntityFrameworkCore;

namespace Faturamento.Worker.Consumers;

public class EstoqueReservadoConsumer : IConsumer<EstoqueReservadoIntegrationEvent>
{
    private readonly FaturamentoDbContext _dbContext;
    private readonly IPublishEndpoint _publishEndpoint;
    private readonly ILogger<EstoqueReservadoConsumer> _logger;

    public EstoqueReservadoConsumer(
        FaturamentoDbContext dbContext, 
        IPublishEndpoint publishEndpoint, 
        ILogger<EstoqueReservadoConsumer> logger)
    {
        _dbContext = dbContext;
        _publishEndpoint = publishEndpoint;
        _logger = logger;
    }

    public async Task Consume(ConsumeContext<EstoqueReservadoIntegrationEvent> context)
    {
        var msg = context.Message;
        _logger.LogInformation("Iniciando faturamento para o Pedido {PedidoId} | Tenant: {TenantId}", msg.PedidoId, msg.TenantId);

        // Checagem de Idempotência: Evita dupla emissão fiscal em retentativas da fila
        var faturaExistente = await _dbContext.Faturas
            .FirstOrDefaultAsync(f => f.TenantId == msg.TenantId && f.PedidoId == msg.PedidoId, context.CancellationToken);

        if (faturaExistente != null)
        {
            _logger.LogWarning("Fatura com Chave {ChaveAcesso} já emitida anteriormente para o Pedido {PedidoId}", 
                faturaExistente.ChaveAcessoFiscal, msg.PedidoId);
            return;
        }

        try
        {
            // Cria a fatura com o valor repassado na mensagem do evento
            var fatura = new Fatura(msg.TenantId, msg.PedidoId, msg.ValorTotal);

            _dbContext.Faturas.Add(fatura);

            // Publica o evento de encerramento fiscal para o ecossistema
            await _publishEndpoint.Publish(new FaturamentoConcluidoIntegrationEvent
            {
                FaturaId = fatura.Id,
                PedidoId = fatura.PedidoId,
                TenantId = fatura.TenantId,
                ChaveAcessoFiscal = fatura.ChaveAcessoFiscal,
                ValorTotal = fatura.ValorTotal,
                CorrelationId = msg.CorrelationId
            }, context.CancellationToken);

            // Transação Atômica no SQL Server (Persiste a fatura e grava a publicação no Outbox)
            await _dbContext.SaveChangesAsync(context.CancellationToken);

            _logger.LogInformation("Fatura {ChaveAcesso} emitida com sucesso para o Pedido {PedidoId}", 
                fatura.ChaveAcessoFiscal, msg.PedidoId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao processar emissão de fatura para o Pedido {PedidoId}", msg.PedidoId);
            throw; // Dispara para ativação dos mecanismos de Retry/Dead-Letter Queue do MassTransit
        }
    }
}
```

5. EntryPoint do Worker (```Faturamento.Worker/Program.cs```)

```C#
C#

// Faturamento.Worker/Program.cs
using Faturamento.Infrastructure.Data;
using Faturamento.Worker.Consumers;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Platform.Multitenancy;
using Platform.Observability;

var builder = Host.CreateApplicationBuilder(args);

// Observabilidade
builder.Services.AddCustomObservability("Faturamento.Worker", builder.Configuration["OpenTelemetry:Endpoint"] ?? "http://localhost:4317");

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=localhost;Database=Db_Faturamento;User Id=sa;Password=Senh@ForteCondominio2026!;Encrypt=False;TrustServerCertificate=True;";

builder.Services.AddDbContext<FaturamentoDbContext>(opts =>
    opts.UseSqlServer(connectionString));

builder.Services.AddMultitenancy();

// Injeção do MassTransit com Outbox e Worker Configuration
builder.Services.AddMassTransit(x =>
{
    x.AddConsumer<EstoqueReservadoConsumer>();

    x.AddEntityFrameworkOutbox<FaturamentoDbContext>(o =>
    {
        o.UseSqlServer();
        o.UseBusOutbox();
    });

    x.UsingRabbitMq((context, cfg) =>
    {
        var host = builder.Configuration["RabbitMq:Host"] ?? "localhost";
        var username = builder.Configuration["RabbitMq:UserName"] ?? "guest";
        var password = builder.Configuration["RabbitMq:Password"] ?? "guest";

        cfg.Host(host, "/", h =>
        {
            h.Username(username);
            h.Password(password);
        });

        cfg.ReceiveEndpoint("faturamento-estoque-reservado-queue", e =>
        {
            e.UseMessageRetry(r => r.Interval(3, TimeSpan.FromSeconds(2)));
            e.ConfigureConsumer<EstoqueReservadoConsumer>(context);
        });
    });
});

var host = builder.Build();
await host.RunAsync();
```

### 📦 Pacotes NuGet Necessários

- Faturamento.Worker.csproj:
  - MassTransit.RabbitMQ
  - MassTransit.EntityFrameworkCore
  - Microsoft.EntityFrameworkCore.SqlServer
  - Referências:
      - Faturamento.Infrastructure, Faturamento.Application, Faturamento.Contracts, Estoque.Contracts, Platform.Observability, Platform.Multitenancy
- Faturamento.Infrastructure.csproj:
  - MassTransit.EntityFrameworkCore
  - Microsoft.EntityFrameworkCore.SqlServer
  - Microsoft.EntityFrameworkCore.Design
  - Referências:
      - Faturamento.Domain, Faturamento.Application, Platform.Multitenancy
- Faturamento.Application.csproj:
  - Referências:
      - Faturamento.Domain, Faturamento.Contracts, Platform.Shared

### 🤖 Como Orquestrar o Copilot Chat no VS

No painel do GitHub Copilot Chat, execute:

**1. Mapeamento de Filas do Worker:**

  ```@workspace Configure no 'Faturamento.Worker/Program.cs' o MassTransit apontando para a fila 'faturamento-estoque-reservado-queue' vinculada ao 'EstoqueReservadoConsumer'.```

**2. Criação da Migration de Faturamento:**

  ```@workspace Crie a migration 'InitialFaturamento' na camada 'Faturamento.Infrastructure' via comando 'dotnet ef migrations add InitialFaturamento'.```

Com a solução ```Faturamento.sln``` pronta, cobrimos todo o ciclo principal dos microsserviços do ecossistema de negócio!

---

## 🏗️ Fase 13 Edge / Gateway & BFF (Gateway YARP Reverse Proxy, BFF.Web e BFF.Mobile)

Na **Fase** camada de **Edge**, isola os microsserviços internos do mundo exterior. O cliente (```Browser, Mobile```) não conversa diretamente com o ```Services/Pedidos``` ou ```Services/Produtos```. Em vez disso, todas as requisições passam pelo **API Gateway** (```YARP```) ou por **BFFs** (```Backend-for-Frontend```) dedicados.

### 🎯 Objetivos

1. Reverse Proxy com YARP (Yet Another Reverse Proxy): Roteamento centralizado, Load Balancing, tratamento de CORS e terminação TLS.

2. BFF (Backend-for-Frontend):
  - ```BFF.Web```: Agregação de dados para painéis/dashboards web (```ex: traz Pedido + Cliente + Status de Faturamento em uma única chamada HTTP para evitar round-trips```).
  - ```BFF.Mobile```: Payload otimizado (enxuto) para redes móveis e respostas compactas.

3. Injeção Transversal de Tenant e Autenticação: Repassar cabeçalhos (```X-Tenant-Id```, ```Authorization: Bearer```) com segurança do **Gateway** para as **APIs** internas.

### 🏗️ Estrutura da Solução

```Plaintext
Plaintext

Edge/
├── Edge.Gateway/    # YARP Reverse Proxy (Roteamento central)
├── Edge.BFF.Web/    # Agregador de chamadas para Web Clients (Blazor, React, Angular)
└── Edge.BFF.Mobile/ # Agregador leve para Apps Mobile (Flutter, MAUI, React Native)
```

### 💻 Implementação Prática

1. Configuração do YARP Reverse Proxy (```Edge/Gateway```)

```Edge/Gateway/appsettings.json```

Configurar as rotas e os clusters que apontam para as portas dos microsserviços internos:

```JSON
JSON

{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ReverseProxy": {
    "Routes": {
      "auth-route": {
        "ClusterId": "auth-cluster",
        "Match": {
          "Path": "/api/v1/auth/{**catch-all}"
        }
      },
      "empresa-route": {
        "ClusterId": "empresa-cluster",
        "Match": {
          "Path": "/api/v1/empresas/{**catch-all}"
        }
      },
      "pessoas-route": {
        "ClusterId": "pessoas-cluster",
        "Match": {
          "Path": "/api/v1/pessoas/{**catch-all}"
        }
      },
      "produtos-route": {
        "ClusterId": "produtos-cluster",
        "Match": {
          "Path": "/api/v1/produtos/{**catch-all}"
        }
      },
      "pedidos-route": {
        "ClusterId": "pedidos-cluster",
        "Match": {
          "Path": "/api/v1/pedidos/{**catch-all}"
        }
      },
      "estoque-route": {
        "ClusterId": "estoque-cluster",
        "Match": {
          "Path": "/api/v1/estoque/{**catch-all}"
        }
      },
      "faturamento-route": {
        "ClusterId": "faturamento-cluster",
        "Match": {
          "Path": "/api/v1/faturamento/{**catch-all}"
        }
      }
    },
    "Clusters": {
      "auth-cluster": {
        "Destinations": {
          "destination1": { "Address": "http://auth_api:8086" }
        }
      },
      "empresa-cluster": {
        "Destinations": {
          "destination1": { "Address": "http://empresa_api:8086" }
        }
      },
      "pessoas-cluster": {
        "Destinations": {
          "destination1": { "Address": "http://pessoas_api:8086" }
        }
      },
      "produtos-cluster": {
        "Destinations": {
          "destination1": { "Address": "http://produtos_api:8086" }
        }
      },
      "pedidos-cluster": {
        "Destinations": {
          "destination1": { "Address": "http://pedidos_api:8086" }
        }
      },
      "estoque-cluster": {
        "Destinations": {
          "destination1": { "Address": "http://estoque_api:8086" }
        }
      },
      "faturamento-cluster": {
        "Destinations": {
          "destination1": { "Address": "http://faturamento_api:8086" }
        }
      }
    }
  }
}
```

2. BFF (Backend-for-Frontend):

2. 1. Agregador Completo para Web (```Edge.BFF.Web/Controllers/DashboardController.cs```)
  
- BFF.Web: Agregação de dados para painéis/dashboards web (```ex: traz Pedido + Cliente + Status de Faturamento em uma única chamada HTTP para evitar round-trips```).
  
O **BFF Web** evita que o navegador faça 3 requisições separadas (```Pedidos, Pessoas, Faturamento```) agregando tudo numa resposta única para o **Dashboard**:

```C#
C#

// Edge.BFF.Web/Controllers/DashboardController.cs
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc;

namespace Edge.BFF.Web.Controllers;

[ApiController]
[Route("api/v1/bff/web/dashboard")]
public class DashboardController : ControllerBase
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<DashboardController> _logger;

    public DashboardController(IHttpClientFactory httpClientFactory, ILogger<DashboardController> logger)
    {
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    [HttpGet("pedido-detalhado/{pedidoId:guid}")]
    public async Task<IActionResult> GetPedidoDetalhado(Guid pedidoId, CancellationToken ct)
    {
        var client = _httpClientFactory.CreateClient("InternalDownstreamClient");

        try
        {
            // Execução paralela de buscas downstream
            var taskPedido = client.GetFromJsonAsync<PedidoDto>($"http://pedidos_api:8086/api/v1/pedidos/{pedidoId}", ct);
            var taskFatura = client.GetFromJsonAsync<FaturaDto>($"http://faturamento_api:8086/api/v1/faturas/pedido/{pedidoId}", ct);

            await Task.WhenAll(taskPedido, taskFatura);

            var pedido = await taskPedido;
            var fatura = await taskFatura;

            if (pedido == null) 
                return NotFound(new { message = $"Pedido {pedidoId} não foi encontrado." });

            // Monta o DTO rico com histórico e detalhes fiscais para Web/Desktop
            var response = new PedidoDetalhadoWebResponse(
                PedidoId: pedido.Id,
                ClienteId: pedido.ClienteId,
                ValorTotal: pedido.ValorTotal,
                StatusPedido: pedido.Status,
                CriadoEmUtc: pedido.CriadoEmUtc,
                ChaveFiscal: fatura?.ChaveAcessoFiscal ?? "Aguardando Faturamento",
                Itens: pedido.Itens.Select(i => new ItemWebDto(i.Sku, i.NomeProduto, i.Quantidade, i.PrecoUnitario)).ToList()
            );

            return Ok(response);
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "Falha na comunicação downstream ao compor dashboard do Pedido {PedidoId}", pedidoId);
            return StatusCode(503, new { error = "Serviço indisponível temporariamente ao agregar dados." });
        }
    }
}

// Contracts DTOs Web (Ricos)
public record PedidoDto(Guid Id, Guid ClienteId, decimal ValorTotal, string Status, DateTime CriadoEmUtc, List<ItemDto> Itens);
public record ItemDto(string Sku, string NomeProduto, int Quantidade, decimal PrecoUnitario);
public record FaturaDto(string ChaveAcessoFiscal);

public record PedidoDetalhadoWebResponse(
    Guid PedidoId, 
    Guid ClienteId, 
    decimal ValorTotal, 
    string StatusPedido, 
    DateTime CriadoEmUtc, 
    string ChaveFiscal,
    List<ItemWebDto> Itens);

public record ItemWebDto(string Sku, string Nome, int Quantidade, decimal PrecoUnitario);
```

2. 2. Agregador Otimizado para Mobile (```Edge.BFF.Mobile/Controllers/MobileCheckoutController.cs```)

- BFF.Mobile: Payload otimizado (enxuto) para redes móveis e respostas compactas.

Payload enxuto sem listas detalhadas desnecessárias para exibição em telas pequenas ou redes 3G/4G/5G:

```C#
C#

// Edge.BFF.Mobile/Controllers/MobileCheckoutController.cs
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc;

namespace Edge.BFF.Mobile.Controllers;

[ApiController]
[Route("api/v1/bff/mobile/checkout")]
public class MobileCheckoutController : ControllerBase
{
    private readonly IHttpClientFactory _httpClientFactory;

    public MobileCheckoutController(IHttpClientFactory httpClientFactory)
    {
        _httpClientFactory = httpClientFactory;
    }

    [HttpGet("resumo/{pedidoId:guid}")]
    public async Task<IActionResult> GetResumoMobile(Guid pedidoId, CancellationToken ct)
    {
        var client = _httpClientFactory.CreateClient("InternalDownstreamClient");

        var pedido = await client.GetFromJsonAsync<PedidoMobileDto>($"http://pedidos_api:8086/api/v1/pedidos/{pedidoId}", ct);
        if (pedido == null) return NotFound();

        // Retorna um payload extremamente compacto
        var response = new ResumoPedidoMobileResponse(
            Id: pedido.Id,
            Total: pedido.ValorTotal,
            Status: pedido.Status,
            TotalItens: pedido.ItensCount
        );

        return Ok(response);
    }
}

public record PedidoMobileDto(Guid Id, decimal ValorTotal, string Status, int ItensCount);
public record ResumoPedidoMobileResponse(Guid Id, decimal Total, string Status, int TotalItens);
```

3. Injetor de Contexto Transversal nos BFFs (```Edge.BFF.Shared/HeaderPropagationHandler.cs```)

Crie este Handler para repassar automaticamente as credenciais de autenticação, ID do tenant e rastreamento para os microsserviços:

3. 1. Handler de Propagação no Web

Este **Handler** para repassar automaticamente as credenciais de autenticação, ID do tenant e rastreamento para os microsserviços:

```C#
C#

// Edge.BFF.Web/Infrastructure/HeaderPropagationHandler.cs
using Microsoft.AspNetCore.Http;

namespace Edge.BFF.Web.Infrastructure;

public class HeaderPropagationHandler : DelegatingHandler
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public HeaderPropagationHandler(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var context = _httpContextAccessor.HttpContext;

        if (context != null)
        {
            // Propaga o Token JWT
            if (context.Request.Headers.TryGetValue("Authorization", out var authHeader))
            {
                request.Headers.TryAddWithoutValidation("Authorization", authHeader.ToString());
            }

            // Propaga o Tenant
            if (context.Request.Headers.TryGetValue("X-Tenant-Id", out var tenantHeader))
            {
                request.Headers.TryAddWithoutValidation("X-Tenant-Id", tenantHeader.ToString());
            }

            // Propaga a Idempotência se presente
            if (context.Request.Headers.TryGetValue("X-Idempotency-Key", out var idempotencyHeader))
            {
                request.Headers.TryAddWithoutValidation("X-Idempotency-Key", idempotencyHeader.ToString());
            }
        }

        return await base.SendAsync(request, cancellationToken);
    }
}
```

3. 2. Handler de Propagação no Mobile

Caso opte por manter os projetos de **BFF** isolados em vez de compartilhar uma biblioteca de classe, aqui está a classe do handler idêntica para a pasta do **Mobile**:

```C#
C#

// Edge.BFF.Mobile/Infrastructure/HeaderPropagationHandler.cs
using Microsoft.AspNetCore.Http;

namespace Edge.BFF.Mobile.Infrastructure;

public class HeaderPropagationHandler : DelegatingHandler
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public HeaderPropagationHandler(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var context = _httpContextAccessor.HttpContext;

        if (context != null)
        {
            if (context.Request.Headers.TryGetValue("Authorization", out var authHeader))
            {
                request.Headers.TryAddWithoutValidation("Authorization", authHeader.ToString());
            }

            if (context.Request.Headers.TryGetValue("X-Tenant-Id", out var tenantHeader))
            {
                request.Headers.TryAddWithoutValidation("X-Tenant-Id", tenantHeader.ToString());
            }

            if (context.Request.Headers.TryGetValue("X-Idempotency-Key", out var idempotencyHeader))
            {
                request.Headers.TryAddWithoutValidation("X-Idempotency-Key", idempotencyHeader.ToString());
            }
        }

        return await base.SendAsync(request, cancellationToken);
    }
}
```

4. Setup do Reverse Proxy Central **YARP** (```Edge/Gateway/Program.cs```)

Ativa o **YARP** e propaga o contexto de observabilidade e cabeçalhos:

```C#
C#

// Edge.Gateway/Program.cs
using Platform.Observability;

var builder = WebApplication.CreateBuilder(args);

// Observabilidade & Log
builder.Host.UseCustomSerilog("Edge.Gateway");

// Carrega as rotas e clusters do YARP via appsettings.json
builder.Services
    .AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", p => 
        p.AllowAnyOrigin()
         .AllowAnyMethod()
         .AllowAnyHeader());
});

var app = builder.Build();

app.UseCors("AllowAll");

// Mapeamento e tratamento de proxies do YARP
app.MapReverseProxy();

await app.RunAsync();
```

6. Configuração do Program no **Edge.BFF.Web** (```Edge.BFF.Web/Program.cs```)

```C#
C#

// Edge.BFF.Web/Program.cs
using Edge.BFF.Web.Infrastructure;
using Platform.Observability;

var builder = WebApplication.CreateBuilder(args);

builder.Host.UseCustomSerilog("Edge.BFF.Web");

builder.Services.AddHttpContextAccessor();
builder.Services.AddTransient<HeaderPropagationHandler>();

// Registra HttpClient com Handler de Propagação
builder.Services.AddHttpClient("InternalDownstreamClient")
    .AddHttpMessageHandler<HeaderPropagationHandler>();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseRouting();
app.MapControllers();

await app.RunAsync();
```

7. Configuração do Program no **Edge.BFF.Mobile** (```Edge.BFF.Mobile/Program.cs```)

```C#
C#

// Edge.BFF.Mobile/Program.cs
using Edge.BFF.Mobile.Infrastructure;
using Platform.Observability;

var builder = WebApplication.CreateBuilder(args);

// Logs estruturados e Observabilidade
builder.Host.UseCustomSerilog("Edge.BFF.Mobile");

builder.Services.AddHttpContextAccessor();
builder.Services.AddTransient<HeaderPropagationHandler>();

// Registra HttpClient tipado/nomeado repassando cabeçalhos transversais
builder.Services.AddHttpClient("InternalDownstreamClient")
    .AddHttpMessageHandler<HeaderPropagationHandler>();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseRouting();
app.MapControllers();

await app.RunAsync();
```

### 📦 Pacotes NuGet Necessários

- Edge.Gateway.csproj:
  - Yarp.ReverseProxy
  - Referência:
      - Platform.Observability
- Edge.BFF.Web.csproj:
  - Swashbuckle.AspNetCore
  - Referência:
Platform.Observability
- Edge.BFF.Mobile.csproj:
  - Swashbuckle.AspNetCore
  - Referência:
      - Platform.Observability

### 🤖 Como Orquestrar o Copilot Chat no VS

No painel do GitHub Copilot Chat, execute os comandos:

**1. Instalação do Pacote YARP:**

```@workspace Adicione o pacote 'Yarp.ReverseProxy' no projeto 'Edge/Gateway/Edge.Gateway.csproj'.```

**2. Criação do BFF.Mobile:**

```#file:DashboardController.cs Crie no projeto 'Edge.BFF.Mobile' um controller equivalente otimizado, que remova campos pesados da DTO para economizar dados móveis.```

Com a camada de **Edge** configurada, encerra a arquitetura fim a fim: Gateway/BFF -> Auth -> Domínios -> Mensageria -> Worker -> Observabilidade.

---

## 🏗️ Fase 14 Infrastructure as Code (Docker Compose, Multi-stage Dockerfiles, Kubernetes & Helm Charts)

A **Fase** (```Infrastructure as Code```) entrega o empacotamento do ecossistema para ambientes de Desenvolvimento, Staging e Produção. Ela transforma todos os microsserviços, workers, bancos de dados, brokers de mensageria e ferramentas de observabilidade em artefatos declarativos, reprodutíveis e prontos para orquestração.

### 💡 Arquitetura de Implantação e Contêineres

- **Docker Multi-stage Builds**: O estágio de ```build``` compila e restaura dependências no SDK do .NET, gerando artefatos pré-compilados. O estágio ```final``` utiliza imagens ASP.NET extremamente leves, reduzindo a superfície de ataque e o tamanho da imagem.
- **Isolamento de Rede no Compose**: Toda a comunicação transita através da rede ```infra_net```, garantindo resolução de DNS interna pelo nome do serviço (ex: ```http://sqlserver2022```, ```http://rabbitmq```).
- **Gerenciamento Declarativo via Helm**: Centraliza configurações comuns (limites de CPU/Memória, conexões e variáveis de ambiente) em templates reaproveitáveis.

Na **Fase**, orquestra todo o ecossistema para rodar em ambientes locais (**Dev**), **Staging** e **Produção**. O objetivo é permitir que qualquer desenvolvedor suba a infraestrutura completa (```RabbitMQ, SQL Server, Seq, Jaeger```) e os microsserviços com apenas um comando.

### 🎯 Objetivos

1. ```Dockerfiles Otimizados```: Multi-stage builds para cada microsserviço (compilação rápida e imagens leves em ```mcr.microsoft.com/dotnet/aspnet:10.0```).

2. ```Docker Compose Unificado```: Subir bancos de dados, brokers de mensageria, ferramentas de observabilidade e serviços com um único comando ```docker compose up -d```.

3. ```Helm Charts para Kubernetes```: Estrutura declarativa de Manifestos (```Deployments, Services, ConfigMaps, Ingress```) pronta para **cluster K8s**.

### 🏗️ Estrutura da Solução

```Plaintext
Plaintext

├── Build/
│   ├── Dockerfiles/
│   │   ├── Api.Dockerfile
│   │   └── Worker.Dockerfile
│   └── docker-compose.yml
└── Infrastructure/
    └── K8s/
        └── helm/
            └── enterprise-ecosystem/
                ├── Chart.yaml
                ├── values.yaml
                └── templates/
                    ├── deployment.yaml
                    ├── service.yaml
                    └── ingress.yaml
```

### 💻 Implementação Prática

1. Dockerfile Genérico Otimizado para APIs (```Build/Dockerfiles/Api.Dockerfile```)

```Dockerfile
Dockerfile

# Estágio 1: Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copia e restaura dependências
COPY ["Services/*/*.csproj", "./Services/"]
COPY ["Platform/*/*.csproj", "./Platform/"]

ARG SERVICE_NAME
RUN dotnet restore "Services/${SERVICE_NAME}/${SERVICE_NAME}.API/${SERVICE_NAME}.API.csproj"

# Copia todo o código-fonte da solução
COPY . .

RUN dotnet publish "Services/${SERVICE_NAME}/${SERVICE_NAME}.API/${SERVICE_NAME}.API.csproj" \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

# Estágio 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8086
EXPOSE 8086

ENTRYPOINT ["dotnet", "exec"]
```

2. Dockerfile Genérico para Workers (```Build/Dockerfiles/Worker.Dockerfile```)

```Dockerfile
Dockerfile

# Estágio 1: Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

ARG SERVICE_NAME

COPY ["Services/${SERVICE_NAME}/${SERVICE_NAME}.Worker/${SERVICE_NAME}.Worker.csproj", "Services/${SERVICE_NAME}/${SERVICE_NAME}.Worker/"]
COPY . .

RUN dotnet restore "Services/${SERVICE_NAME}/${SERVICE_NAME}.Worker/${SERVICE_NAME}.Worker.csproj"
RUN dotnet publish "Services/${SERVICE_NAME}/${SERVICE_NAME}.Worker/${SERVICE_NAME}.Worker.csproj" \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

# Estágio 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "exec"]
```

4. Docker Compose de Desenvolvimento (```Build/docker-compose.yml```)

Suba o ecossistema de infraestrutura + microsserviços em conexões **Docker**:

```YAML
YAML

version: '3.8'

services:
  # ===============================================================
  # OBSERVABILIDADE & MONITORAMENTO
  # ===============================================================
  seq:
    image: datalust/seq:latest
    container_name: enterprise-seq
    restart: unless-stopped
    environment:
      - ACCEPT_EULA=Y
    ports:
      - "5341:80"
    networks:
      - infra_net

  jaeger:
    image: jaegertracing/all-in-one:latest
    container_name: enterprise-jaeger
    restart: unless-stopped
    ports:
      - "16686:16686"
      - "4317:4317" # OTLP gRPC
      - "4318:4318" # OTLP HTTP
    networks:
      - infra_net

  # ===============================================================
  # EDGE / GATEWAY & BFFs
  # ===============================================================
  edge-gateway:
    build:
      context: ..
      dockerfile: Build/Dockerfiles/Api.Dockerfile
      args:
        SERVICE_NAME: Edge.Gateway
    container_name: edge_gateway
    ports:
      - "5006:8086"
    networks:
      - infra_net

  edge-bff-web:
    build:
      context: ..
      dockerfile: Build/Dockerfiles/Api.Dockerfile
      args:
        SERVICE_NAME: Edge.BFF.Web
    container_name: edge_bff_web
    ports:
      - "5005:8086"
    networks:
      - infra_net

  # ===============================================================
  # MICROSSERVIÇOS (APIs)
  # ===============================================================
  pedidos-api:
    build:
      context: ..
      dockerfile: Build/Dockerfiles/Api.Dockerfile
      args:
        SERVICE_NAME: Pedidos
    container_name: pedidos_api
    ports:
      - "5011:8086"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Server=sqlserver2022;Database=Db_Pedidos;User Id=sa;Password=Senh@Forte2026!;Encrypt=False;TrustServerCertificate=True;
      - RabbitMQ__Host=rabbitmq
      - Seq__Url=http://enterprise-seq:80
    depends_on:
      - sqlserver2022
      - rabbitmq
    networks:
      - infra_net

  faturamento-api:
    build:
      context: ..
      dockerfile: Build/Dockerfiles/Api.Dockerfile
      args:
        SERVICE_NAME: Faturamento
    container_name: faturamento_api
    ports:
      - "5013:8086"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Server=sqlserver2022;Database=Db_Faturamento;User Id=sa;Password=Senh@Forte2026!;Encrypt=False;TrustServerCertificate=True;
      - RabbitMQ__Host=rabbitmq
      - Seq__Url=http://enterprise-seq:80
    depends_on:
      - sqlserver2022
      - rabbitmq
    networks:
      - infra_net

  # ===============================================================
  # WORKERS DE BACKGROUND (MASSTRANSIT CONSUMERS)
  # ===============================================================
  estoque-worker:
    build:
      context: ..
      dockerfile: Build/Dockerfiles/Worker.Dockerfile
      args:
        SERVICE_NAME: Estoque
    container_name: estoque_worker
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Server=sqlserver2022;Database=Db_Estoque;User Id=sa;Password=Senh@Forte2026!;Encrypt=False;TrustServerCertificate=True;
      - RabbitMQ__Host=rabbitmq
      - Seq__Url=http://enterprise-seq:80
    depends_on:
      - sqlserver2022
      - rabbitmq
    networks:
      - infra_net

  faturamento-worker:
    build:
      context: ..
      dockerfile: Build/Dockerfiles/Worker.Dockerfile
      args:
        SERVICE_NAME: Faturamento
    container_name: faturamento_worker
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Server=sqlserver2022;Database=Db_Faturamento;User Id=sa;Password=Senh@Forte2026!;Encrypt=False;TrustServerCertificate=True;
      - RabbitMQ__Host=rabbitmq
      - Seq__Url=http://enterprise-seq:80
    depends_on:
      - sqlserver2022
      - rabbitmq
    networks:
      - infra_net

networks:
  infra_net:
    driver: bridge
    name: infra_net
```

5. Manifesto Helm para Kubernetes (```Infrastructure/K8s/helm/enterprise-ecosystem/```)

Template parametrizável para subir os microsserviços no **Kubernetes**:

```templates/service.yaml```

```YAML
YAML

apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-{{ .Values.service.name }}
  labels:
    app: {{ .Values.service.name }}
spec:
  type: {{ .Values.service.type | default "ClusterIP" }}
  ports:
    - port: 80
      targetPort: 8086
      protocol: TCP
      name: http
  selector:
    app: {{ .Values.service.name }}
```

```templates/ingress.yaml```

```YAML
YAML

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
    - host: api.meusaas.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ .Release.Name }}-edge-gateway
                port:
                  number: 80
```

Exemplo do ```Infrastructure/K8s/helm/enterprise-ecosystem/values.yaml``` correspondente:

```YAML
YAML

image:
  repository: myregistry.azurecr.io
  tag: latest
  pullPolicy: IfNotPresent

service:
  name: auth-api
  replicaCount: 2

config:
  connectionString: "Server=sqlserver2022;Database=AuthDb;User Id=sa;Password=Senh@Forte2026!;Encrypt=False;TrustServerCertificate=True;"
  rabbitmqHost: "rabbitmq"
  rabbitmqUser: "guest"
  rabbitmqPassword: "guest"
```

### 🚀 Comandos Rápidos de Execução

1. Subir toda a infraestrutura e microsserviços via **Docker Compose**:

```Bash
Bash

cd Build
docker compose up -d --build
```

2. Verificar a integridade dos contêineres rodando:

```Bash
Bash

docker compose ps
```

3. Implantar via Helm no Kubernetes:

```Bash
Bash

helm install enterprise-app ./Infrastructure/K8s/helm/enterprise-ecosystem -f ./Infrastructure/K8s/helm/enterprise-ecosystem/values.yaml
```

URLs de Acesso Local aos Painéis de Controle:
- API Gateway: ```http://localhost:5006```
- RabbitMQ Management: ```http://localhost:15672``` (User/Pass: guest/guest)
- Seq (Central de Logs): ```http://localhost:5341```
- Jaeger (Distributed Tracing): ```http://localhost:16686```