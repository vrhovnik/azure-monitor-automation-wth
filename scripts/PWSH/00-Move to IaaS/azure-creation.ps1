<# 
# SYNOPSIS
# Installs resources with applications and opens remote desktop connection to the resource
#
# DESCRIPTION
# installs all neccessary file to be installed on VM with getting back address to be able to access it
#
# NOTES
# Author      : Bojan Vrhovnik
# GitHub      : https://github.com/vrhovnik
# Version 0.2.3
# SHORT CHANGE DESCRIPTION: moved bicep instructions to separate file and added default browser opener 
#>
$regionToDeploy = "WestEurope"
Write-Host "Creating resources in $regionToDeploy"
$data = az deployment sub create --location $regionToDeploy --template-file rg.bicep --parameters rg.parameters.json | ConvertFrom-Json | Select-Object properties
$rgName=$data.properties.outputs.rgName.value
Write-Host "Resource group $rgName has been created"
$vmSettings=az deployment group create --resource-group $rgName --template-file vm.bicep --parameters vm.parameters.json |ConvertFrom-Json |Select-Object properties
$myIp=$vmSettings.properties.outputs.publicIP.value

Write-Host "VM created, opening remote desktop to $myIp"
$args = New-Object -TypeName System.Collections.Generic.List[System.String]
$args.Add("/v:$($myIp):3389")
$args.Add("/f")
#open RDP
Start-Process "$env:windir\system32\mstsc.exe" -ArgumentList $args