FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8086
ENV ASPNETCORE_URLS=http://+:8086

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Services/Empresa/Empresa.API/Empresa.API.csproj", "Services/Empresa/Empresa.API/"]
COPY ["Services/Empresa/Empresa.Infrastructure/Empresa.Infrastructure.csproj", "Services/Empresa/Empresa.Infrastructure/"]
COPY ["Services/Empresa/Empresa.Application/Empresa.Application.csproj", "Services/Empresa/Empresa.Application/"]
COPY ["Services/Empresa/Empresa.Domain/Empresa.Domain.csproj", "Services/Empresa/Empresa.Domain/"]
COPY ["Services/Empresa/Empresa.Contracts/Empresa.Contracts.csproj", "Services/Empresa/Empresa.Contracts/"]
COPY ["Platform/", "Platform/"]
RUN dotnet restore "Services/Empresa/Empresa.API/Empresa.API.csproj"
COPY . .
WORKDIR "/src/Services/Empresa/Empresa.API"
RUN dotnet build "Empresa.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Empresa.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Empresa.API.dll"]
