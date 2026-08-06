FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8086
ENV ASPNETCORE_URLS=http://+:8086

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG SERVICE_NAME
WORKDIR /src
COPY . .
RUN dotnet restore "Services/\/\.API/\.API.csproj"
RUN dotnet build "Services/\/\.API/\.API.csproj" -c Release -o /app/build

FROM build AS publish
ARG SERVICE_NAME
RUN dotnet publish "Services/\/\.API/\.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ExecuteService.dll"]
