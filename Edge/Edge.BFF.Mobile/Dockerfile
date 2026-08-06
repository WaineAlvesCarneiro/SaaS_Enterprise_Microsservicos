FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8086
ENV ASPNETCORE_URLS=http://+:8086

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Edge/Edge.BFF.Mobile/Edge.BFF.Mobile.csproj", "Edge/Edge.BFF.Mobile/"]
COPY ["Platform/", "Platform/"]
RUN dotnet restore "Edge/Edge.BFF.Mobile/Edge.BFF.Mobile.csproj"
COPY . .
WORKDIR "/src/Edge/Edge.BFF.Mobile"
RUN dotnet build "Edge.BFF.Mobile.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Edge.BFF.Mobile.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Edge.BFF.Mobile.dll"]
