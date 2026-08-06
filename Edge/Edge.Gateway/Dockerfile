FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8086
ENV ASPNETCORE_URLS=http://+:8086

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Edge/Edge.Gateway/Edge.Gateway.csproj", "Edge/Edge.Gateway/"]
COPY ["Platform/", "Platform/"]
RUN dotnet restore "Edge/Edge.Gateway/Edge.Gateway.csproj"
COPY . .
WORKDIR "/src/Edge/Edge.Gateway"
RUN dotnet build "Edge.Gateway.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Edge.Gateway.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Edge.Gateway.dll"]
