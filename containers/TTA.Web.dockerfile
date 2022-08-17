FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app

EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["TTA.Web/TTA.Web.csproj", "TTA.Web/"]
RUN dotnet restore "TTA.Web/TTA.Web.csproj"
COPY . .
WORKDIR "/src/TTA.Web"
RUN dotnet build "TTA.Web.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "TTA.Web.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "TTA.Web.dll"]