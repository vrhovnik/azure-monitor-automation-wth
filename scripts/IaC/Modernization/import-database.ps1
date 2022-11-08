<# 
# SYNOPSIS
# import database from bacpac file to Azure SQL
#
# DESCRIPTION
# import database from bacpac file to Azure SQL
#
# NOTES
# Author      : Bojan Vrhovnik
# GitHub      : https://github.com/vrhovnik
# Version 0.1.2
# SHORT CHANGE DESCRIPTION: adding parameters
#>
param([string]$databaseName="TTADB",
    [string]$serverName="amadatattasqlserver")

Write-Host "Importing data to $databaseName on $serverName"
az sql db import -s $serverName -n databaseName --storage-key-type SharedAccessKey --storage-uri "https://webeudatastorage.blob.core.windows.net/ama/TTADB.bacpac" -g "rg-${{ env.CUSTOMER_NAME }}" -p "Sql@news0l1!" -u ttasql --storage-key "?sv=2021-04-10&st=2022-11-07T07%3A57%3A00Z&se=2023-01-01T07%3A57%3A00Z&sr=b&sp=r&sig=MvPfn1rNRdzX2sESe23f5H2R0IpUTKgs79B8%2FRarzSY%3D"
Write-Host "Importing data to $databaseName on $serverName completed"