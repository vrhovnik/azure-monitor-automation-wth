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
RUN dotnet restore "TTA.StatGenerator/TTA.StatGenerator.csproj"

COPY . .

WORKDIR "/src/"
RUN dotnet restore "TTA.Core/TTA.Core.csproj"
RUN dotnet restore "TTA.Models/TTA.Models.csproj"
RUN dotnet restore "TTA.Interfaces/TTA.Interfaces.csproj"
RUN dotnet restore "TTA.SQL/TTA.SQL.csproj"

RUN dotnet build "TTA.Core/TTA.Core.csproj" -c Release -o /TTA.StatGenerator
RUN dotnet build "TTA.Models/TTA.Models.csproj" -c Release -o /TTA.StatGenerator
RUN dotnet build "TTA.Interfaces/TTA.Interfaces.csproj" -c Release -o /TTA.StatGenerator
RUN dotnet build "TTA.SQL/TTA.SQL.csproj" -c Release -o /TTA.StatGenerator
RUN dotnet build "TTA.StatGenerator/TTA.StatGenerator.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "TTA.StatGenerator/TTA.StatGenerator.csproj" -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:6.0 as final

WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "TTA.StatGenerator.dll"]