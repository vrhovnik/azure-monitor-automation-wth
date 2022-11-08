FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["TTASLN/TTA.Models/", "TTA.Models/"]
COPY ["TTASLN/TTA.Interfaces/", "TTA.Interfaces/"]
COPY ["TTASLN/TTA.Core/", "TTA.Core/"]
COPY ["TTASLN/TTA.SQL/", "TTA.SQL/"]
COPY ["TTASLN/TTA.StatGenerator/", "TTA.StatGenerator"]

RUN dotnet restore "TTA.Core/TTA.Core.csproj"
RUN dotnet restore "TTA.Models/TTA.Models.csproj"
RUN dotnet restore "TTA.Interfaces/TTA.Interfaces.csproj"
RUN dotnet restore "TTA.SQL/TTA.SQL.csproj"
RUN dotnet restore "TTA.DataGenerator.SQL/TTA.DataGenerator.SQL.csproj"

COPY . .

WORKDIR "/src/"
RUN dotnet restore "TTA.Core/TTA.Core.csproj"
RUN dotnet restore "TTA.Models/TTA.Models.csproj"
RUN dotnet restore "TTA.Interfaces/TTA.Interfaces.csproj"
RUN dotnet restore "TTA.SQL/TTA.SQL.csproj"

RUN dotnet build "TTA.Core/TTA.Core.csproj" -c Release -o /TTA.DataGenerator.SQL
RUN dotnet build "TTA.Models/TTA.Models.csproj" -c Release -o /TTA.DataGenerator.SQL
RUN dotnet build "TTA.Interfaces/TTA.Interfaces.csproj" -c Release -o /TTA.DataGenerator.SQL
RUN dotnet build "TTA.SQL/TTA.SQL.csproj" -c Release -o /TTA.DataGenerator.SQL
RUN dotnet build "TTA.DataGenerator.SQL/TTA.DataGenerator.SQL.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "TTA.DataGenerator.SQL/TTA.DataGenerator.SQL.csproj" -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:6.0 as final

ENV CREATE_TABLES false
ENV DEFAULT_PASSWORD Password1!
ENV DROP_DATABASE false
ENV RECORD_NUMBER 100

WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "TTA.DataGenerator.SQL.dll"]