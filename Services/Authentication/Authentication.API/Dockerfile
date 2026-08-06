FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8086
ENV ASPNETCORE_URLS=http://+:8086

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Services/Authentication/Authentication.API/Authentication.API.csproj", "Services/Authentication/Authentication.API/"]
COPY ["Services/Authentication/Authentication.Infrastructure/Authentication.Infrastructure.csproj", "Services/Authentication/Authentication.Infrastructure/"]
COPY ["Services/Authentication/Authentication.Application/Authentication.Application.csproj", "Services/Authentication/Authentication.Application/"]
COPY ["Services/Authentication/Authentication.Domain/Authentication.Domain.csproj", "Services/Authentication/Authentication.Domain/"]
COPY ["Services/Authentication/Authentication.Contracts/Authentication.Contracts.csproj", "Services/Authentication/Authentication.Contracts/"]
COPY ["Platform/", "Platform/"]
RUN dotnet restore "Services/Authentication/Authentication.API/Authentication.API.csproj"
COPY . .
WORKDIR "/src/Services/Authentication/Authentication.API"
RUN dotnet build "Authentication.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Authentication.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Authentication.API.dll"]
