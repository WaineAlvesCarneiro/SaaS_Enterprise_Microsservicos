FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8086
ENV ASPNETCORE_URLS=http://+:8086

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Edge/Edge.BFF.Web/Edge.BFF.Web.csproj", "Edge/Edge.BFF.Web/"]
COPY ["Platform/", "Platform/"]
RUN dotnet restore "Edge/Edge.BFF.Web/Edge.BFF.Web.csproj"
COPY . .
WORKDIR "/src/Edge/Edge.BFF.Web"
RUN dotnet build "Edge.BFF.Web.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Edge.BFF.Web.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Edge.BFF.Web.dll"]
