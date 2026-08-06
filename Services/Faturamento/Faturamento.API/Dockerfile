FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8086
ENV ASPNETCORE_URLS=http://+:8086

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Services/Faturamento/Faturamento.API/Faturamento.API.csproj", "Services/Faturamento/Faturamento.API/"]
COPY ["Services/Faturamento/Faturamento.Infrastructure/Faturamento.Infrastructure.csproj", "Services/Faturamento/Faturamento.Infrastructure/"]
COPY ["Services/Faturamento/Faturamento.Application/Faturamento.Application.csproj", "Services/Faturamento/Faturamento.Application/"]
COPY ["Services/Faturamento/Faturamento.Domain/Faturamento.Domain.csproj", "Services/Faturamento/Faturamento.Domain/"]
COPY ["Services/Faturamento/Faturamento.Contracts/Faturamento.Contracts.csproj", "Services/Faturamento/Faturamento.Contracts/"]
COPY ["Platform/", "Platform/"]
RUN dotnet restore "Services/Faturamento/Faturamento.API/Faturamento.API.csproj"
COPY . .
WORKDIR "/src/Services/Faturamento/Faturamento.API"
RUN dotnet build "Faturamento.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Faturamento.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Faturamento.API.dll"]
