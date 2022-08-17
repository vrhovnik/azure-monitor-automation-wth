FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

COPY ["TTASLN/TTA.Models/", "TTA.Models/"]
COPY ["TTASLN/TTA.Interfaces/", "TTA.Interfaces/"]
COPY ["TTASLN/TTA.Core/", "TTA.Core/"]
COPY ["TTASLN/TTA.SQL/", "TTA.SQL/"]
COPY ["TTASLN/TTA.Web/", "TTA.Web/"]


RUN dotnet restore "TTA.Core/TTA.Core.csproj"
RUN dotnet restore "TTA.Models/TTA.Models.csproj"
RUN dotnet restore "TTA.Interfaces/TTA.Interfaces.csproj"
RUN dotnet restore "TTA.SQL/TTA.SQL.csproj"
RUN dotnet restore "TTA.Web/TTA.Web.csproj"

COPY . .

WORKDIR "/src/"
RUN dotnet restore "TTA.Core/TTA.Core.csproj"
RUN dotnet restore "TTA.Models/TTA.Models.csproj"
RUN dotnet restore "TTA.Interfaces/TTA.Interfaces.csproj"
RUN dotnet restore "TTA.SQL/TTA.SQL.csproj"
RUN dotnet restore "TTA.Web/TTA.Web.csproj"

RUN dotnet build "TTA.Core/TTA.Core.csproj" -c Release -o /TTA.Web
RUN dotnet build "TTA.Models/TTA.Models.csproj" -c Release -o /TTA.Web
RUN dotnet build "TTA.Interfaces/TTA.Interfaces.csproj" -c Release -o /TTA.Web
RUN dotnet build "TTA.SQL/TTA.SQL.csproj" -c Release -o /TTA.Web
RUN dotnet build "TTA.Web/TTA.Web.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "TTA.Web/TTA.Web.csproj" -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:6.0 as final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "TTA.Web.dll"]