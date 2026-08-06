FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8086
ENV ASPNETCORE_URLS=http://+:8086

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Services/Produtos/Produtos.API/Produtos.API.csproj", "Services/Produtos/Produtos.API/"]
COPY ["Services/Produtos/Produtos.Infrastructure/Produtos.Infrastructure.csproj", "Services/Produtos/Produtos.Infrastructure/"]
COPY ["Services/Produtos/Produtos.Application/Produtos.Application.csproj", "Services/Produtos/Produtos.Application/"]
COPY ["Services/Produtos/Produtos.Domain/Produtos.Domain.csproj", "Services/Produtos/Produtos.Domain/"]
COPY ["Services/Produtos/Produtos.Contracts/Produtos.Contracts.csproj", "Services/Produtos/Produtos.Contracts/"]
COPY ["Platform/", "Platform/"]
RUN dotnet restore "Services/Produtos/Produtos.API/Produtos.API.csproj"
COPY . .
WORKDIR "/src/Services/Produtos/Produtos.API"
RUN dotnet build "Produtos.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Produtos.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Produtos.API.dll"]
