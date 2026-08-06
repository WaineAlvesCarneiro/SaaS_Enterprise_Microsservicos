FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8086
ENV ASPNETCORE_URLS=http://+:8086

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Services/Pessoas/Pessoas.API/Pessoas.API.csproj", "Services/Pessoas/Pessoas.API/"]
COPY ["Services/Pessoas/Pessoas.Infrastructure/Pessoas.Infrastructure.csproj", "Services/Pessoas/Pessoas.Infrastructure/"]
COPY ["Services/Pessoas/Pessoas.Application/Pessoas.Application.csproj", "Services/Pessoas/Pessoas.Application/"]
COPY ["Services/Pessoas/Pessoas.Domain/Pessoas.Domain.csproj", "Services/Pessoas/Pessoas.Domain/"]
COPY ["Services/Pessoas/Pessoas.Contracts/Pessoas.Contracts.csproj", "Services/Pessoas/Pessoas.Contracts/"]
COPY ["Platform/", "Platform/"]
RUN dotnet restore "Services/Pessoas/Pessoas.API/Pessoas.API.csproj"
COPY . .
WORKDIR "/src/Services/Pessoas/Pessoas.API"
RUN dotnet build "Pessoas.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Pessoas.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Pessoas.API.dll"]
