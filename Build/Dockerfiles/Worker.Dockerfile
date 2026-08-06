FROM mcr.microsoft.com/dotnet/runtime:10.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG SERVICE_NAME
WORKDIR /src
COPY . .
RUN dotnet restore "Services/\/\.Worker/\.Worker.csproj"
RUN dotnet build "Services/\/\.Worker/\.Worker.csproj" -c Release -o /app/build

FROM build AS publish
ARG SERVICE_NAME
RUN dotnet publish "Services/\/\.Worker/\.Worker.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ExecuteService.dll"]
