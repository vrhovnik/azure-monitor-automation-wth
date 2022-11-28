<# 
# SYNOPSIS
# Installs VM with scripts
#
# DESCRIPTION
# prepared all neccessary applications on VM
#
# NOTES
# Author      : Bojan Vrhovnik
# GitHub      : https://github.com/vrhovnik
# Version 0.6.2
# SHORT CHANGE DESCRIPTION: adding function support to prettify the output and set the location to correct folder
#>
param(
    [string]$regionToDeploy="westeurope",
    [string]$rgName="rg-cust-ama-ce-2",
    [string]$adminName="ttadmin",
    [string]$adminPass="Complic4tedP@ssw0rd1!",
    [string]$workDir="C:/Work/Projects/azure-monitor-automation-wth"    
)

function CreateResourceGroup($rgName,$regionToDeploy){
    Write-host "Setting $workDir as working directory and moving to modernization folder"
    Write-Host "Creating resource group $rgName in $regionToDeploy"
    az deployment sub create --location $regionToDeploy --template-file rg.bicep --parameters resourceGroupName=$rgName resourceGroupLocation=$regionToDeploy
    Write-Host "Resource group $rgName created (or updated)"
}

function CreateVM($rgName,$vmName,$adminName,$adminPass) {
    Write-Host "Creating VM $vmName in $rgName"
    if ($vmName -eq "") {
        $vmName = "vm$(-join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_}))"
    }
    $ipName="ip-$vmName"
    $dnsname="dns-$vmName"
    Write-Host "Creating IP $ipName, deploying VM $vmName"
    $myIp=az deployment group create --resource-group $rgName --template-file vm.bicep --parameters publicIpAddressName=$ipName dnsNameForIp=$dnsname vmName=$vmName windowsAdminUsername=$adminName windowsAdminPassword=$adminPass
    Write-Host "VM created, opening remote desktop to $myIp"
    $args = New-Object -TypeName System.Collections.Generic.List[System.String]
    $args.Add("/v:$($myIp):3389")
    $args.Add("/f")
    #open RDP
    Start-Process "$env:windir\system32\mstsc.exe" -ArgumentList $args
}
# 0. set the location
Set-Location "$workDir/scripts/IaC/VM"
# 1. deploy or update resource group
CreateResourceGroup -rgName $rgName -regionToDeploy $regionToDeploy
# 2. deploy VM
CreateVM -rgName $rgName -vmName $vmName -adminName $adminName -adminPass $adminPass
