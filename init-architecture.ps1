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
  # (Conectam-se à rede 'infra_net' criada na Fase 1)
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
# REDE EXTERNA COMPARTILHADA (Criada na Fase 1)
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