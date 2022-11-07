<# 
# SYNOPSIS
# create resources with script and bicep
#
# DESCRIPTION
# creates resource groups and VM with the use of Bicep
#
# NOTES
# Author      : Bojan Vrhovnik
# GitHub      : https://github.com/vrhovnik
# Version 0.2.4 
#>
param(
    [string]$regionToDeploy = "WestEurope",
    [string[]]$customers = @("cust-ama-2", "cust-ama-3")
)

Write-Host "Creating resources in $regionToDeploy"
#what if checks
for ($index = 0; $index -lt $customers.count; $index++)
{
    $currentRgName = "rg-$($customers[$index])"
    Write-Host "Current" $currentRgName
    az deployment sub what-if --name $currentRgName --location $regionToDeploy --template-file rg.bicep --parameters resourceGroupName=$currentRgName
}

#deploy to production
for ($index = 0; $index -lt $customers.count; $index++)
{
    $currentRgName = "rg-$($customers[$index])"
    Write-Host "Current" $currentRgName
    
    az deployment sub create --name $currentRgName --location $regionToDeploy --template-file rg.bicep --parameters resourceGroupName=$currentRgName
    Write-Host $currentRgName "was created"
    $currentVMName = "vm-$($customers[$index])"
    Write-Host "Current VM name " $currentVMName
    az deployment group what-if --resource-group $currentRgName --template-file vm.bicep --parameters vmName="$currentRgName-vm-$index" windowsAdminUsername="tta-admin" windowsAdminPassword="tta-P@ssw0rd1!" vmName=$currentVMName
    az deployment group create --resource-group $currentRgName --template-file vm.bicep --parameters vmName="$currentRgName-vm-$index" windowsAdminUsername="tta-admin" windowsAdminPassword="tta-P@ssw0rd1!" vmName=$currentVMName
}
Write-Host "Done with creating resources"



