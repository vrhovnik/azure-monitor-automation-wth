FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

COPY ["TTASLN/TTA.Models/", "TTA.Models/"]
COPY ["TTASLN/TTA.Core/", "TTA.Core/"]
COPY ["TTASLN/TTA.DataGenerator.SQL/", "TTA.DataGenerator.SQL"]

RUN dotnet restore "TTA.Core/TTA.Core.csproj"
RUN dotnet restore "TTA.Models/TTA.Models.csproj"
RUN dotnet restore "TTA.DataGenerator.SQL/TTA.DataGenerator.SQL.csproj"

COPY . .

WORKDIR "/src/"

RUN dotnet restore "TTA.Core/TTA.Core.csproj"
RUN dotnet restore "TTA.Models/TTA.Models.csproj"
RUN dotnet restore "TTA.DataGenerator.SQL/TTA.DataGenerator.SQL.csproj"

RUN dotnet build "TTA.Core/TTA.Core.csproj" -c Release -o /TTA.DataGenerator.SQL
RUN dotnet build "TTA.Models/TTA.Models.csproj" -c Release -o /TTA.DataGenerator.SQL
RUN dotnet build "TTA.DataGenerator.SQL/TTA.DataGenerator.SQL.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "TTA.DataGenerator.SQL/TTA.DataGenerator.SQL.csproj" -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:6.0 as final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "TTA.DataGenerator.SQL.dll"]