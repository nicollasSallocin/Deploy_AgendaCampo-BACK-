# Etapa de Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copia e restaura o projeto a partir da subpasta AgendaCampo
COPY ["AgendaCampo/AgendaCampo.csproj", "AgendaCampo/"]
RUN dotnet restore "AgendaCampo/AgendaCampo.csproj"

# Copia todo o código-fonte
COPY . .

# Altera o diretório para executar o publish da aplicação
WORKDIR "/src/AgendaCampo"
RUN dotnet publish "AgendaCampo.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Etapa Final (Runtime)
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

COPY --from=build /app/publish .

# Define a porta padrão dinamicamente (útil para plataformas de deploy como Render, Railway, Heroku)
ENV PORT=8080
ENV ASPNETCORE_URLS=http://+:${PORT}

EXPOSE 8080

ENTRYPOINT ["dotnet", "AgendaCampo.dll"]