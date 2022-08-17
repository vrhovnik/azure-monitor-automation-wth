FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

COPY ["TTASLN/TTA.StatGenerator/", "TTA.StatGenerator"]

RUN dotnet restore "TTA.StatGenerator/TTA.StatGenerator.csproj"

COPY . .

WORKDIR "/src/"
RUN dotnet build "TTA.StatGenerator/TTA.StatGenerator.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "TTA.StatGenerator/TTA.StatGenerator.csproj" -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:6.0 as final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "TTA.StatGenerator.dll"]