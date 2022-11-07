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
    az deployment sub what-if --location $regionToDeploy --template-file rg.bicep --param resourceGroupName=$currentRgName
}

#deployment to production
for ($index = 0; $index -lt $customers.count; $index++)
{
    $currentRgName = "rg-$($customers[$index])"
    Write-Host "Current" $currentRgName
    $data = az deployment sub create --location $regionToDeploy --template-file rg.bicep --param resourceGroupName=$currentRgName
    $rgName = $data.properties.outputs.rgName.value
    Write-Host $rgName "was created"
    az deployment group what-if --resource-group $rgName --template-file vm.bicep --parameters vmName="$currentRgName-vm-$index" adminUsername="tta-admin" adminPassword="tta-P@ssw0rd1!"
    az deployment group create --resource-group $rgName --template-file vm.bicep --parameters vmName="$currentRgName-vm-$index" adminUsername="tta-admin" adminPassword="tta-P@ssw0rd1!"
}
Write-Host "Done with creating resources"



