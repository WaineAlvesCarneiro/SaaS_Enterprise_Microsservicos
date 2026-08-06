FROM mcr.microsoft.com/dotnet/runtime:10.0 AS base
WORKDIR /app


FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Services/Notification/Notification.Worker/Notification.Worker.csproj", "Services/Notification/Notification.Worker/"]
COPY ["Services/Notification/Notification.Infrastructure/Notification.Infrastructure.csproj", "Services/Notification/Notification.Infrastructure/"]
COPY ["Services/Notification/Notification.Application/Notification.Application.csproj", "Services/Notification/Notification.Application/"]
COPY ["Services/Notification/Notification.Domain/Notification.Domain.csproj", "Services/Notification/Notification.Domain/"]
COPY ["Services/Notification/Notification.Contracts/Notification.Contracts.csproj", "Services/Notification/Notification.Contracts/"]
COPY ["Platform/", "Platform/"]
RUN dotnet restore "Services/Notification/Notification.Worker/Notification.Worker.csproj"
COPY . .
WORKDIR "/src/Services/Notification/Notification.Worker"
RUN dotnet build "Notification.Worker.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Notification.Worker.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Notification.Worker.dll"]
