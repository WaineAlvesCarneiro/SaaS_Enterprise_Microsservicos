FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8086
ENV ASPNETCORE_URLS=http://+:8086

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Services/Estoque/Estoque.API/Estoque.API.csproj", "Services/Estoque/Estoque.API/"]
COPY ["Services/Estoque/Estoque.Infrastructure/Estoque.Infrastructure.csproj", "Services/Estoque/Estoque.Infrastructure/"]
COPY ["Services/Estoque/Estoque.Application/Estoque.Application.csproj", "Services/Estoque/Estoque.Application/"]
COPY ["Services/Estoque/Estoque.Domain/Estoque.Domain.csproj", "Services/Estoque/Estoque.Domain/"]
COPY ["Services/Estoque/Estoque.Contracts/Estoque.Contracts.csproj", "Services/Estoque/Estoque.Contracts/"]
COPY ["Platform/", "Platform/"]
RUN dotnet restore "Services/Estoque/Estoque.API/Estoque.API.csproj"
COPY . .
WORKDIR "/src/Services/Estoque/Estoque.API"
RUN dotnet build "Estoque.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Estoque.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Estoque.API.dll"]
