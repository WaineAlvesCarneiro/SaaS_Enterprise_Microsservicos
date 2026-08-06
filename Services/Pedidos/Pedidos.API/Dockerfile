FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8086
ENV ASPNETCORE_URLS=http://+:8086

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Services/Pedidos/Pedidos.API/Pedidos.API.csproj", "Services/Pedidos/Pedidos.API/"]
COPY ["Services/Pedidos/Pedidos.Infrastructure/Pedidos.Infrastructure.csproj", "Services/Pedidos/Pedidos.Infrastructure/"]
COPY ["Services/Pedidos/Pedidos.Application/Pedidos.Application.csproj", "Services/Pedidos/Pedidos.Application/"]
COPY ["Services/Pedidos/Pedidos.Domain/Pedidos.Domain.csproj", "Services/Pedidos/Pedidos.Domain/"]
COPY ["Services/Pedidos/Pedidos.Contracts/Pedidos.Contracts.csproj", "Services/Pedidos/Pedidos.Contracts/"]
COPY ["Platform/", "Platform/"]
RUN dotnet restore "Services/Pedidos/Pedidos.API/Pedidos.API.csproj"
COPY . .
WORKDIR "/src/Services/Pedidos/Pedidos.API"
RUN dotnet build "Pedidos.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Pedidos.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Pedidos.API.dll"]
