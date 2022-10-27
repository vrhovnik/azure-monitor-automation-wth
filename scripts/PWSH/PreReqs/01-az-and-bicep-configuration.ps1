# login to Azure account
az login
az account list --output table
# check account
$answer = Read-Host "Install bicep? (y/n)"
if ($answer -eq "y")
{
    ## upgrade bicep to latest version
    # if you don't have it installed 
    # EXAMPLE with Chocolatey
    # choco install bicep
    # EXAMPLE with Winget
    #  winget install -e --id Microsoft.Bicep
    # EXAMPLE with Powershell
    ## Create the install folder
    $installPath = "$env:USERPROFILE\.bicep"
    $installDir = New-Item -ItemType Directory -Path $installPath -Force
    $installDir.Attributes += 'Hidden'
    # Fetch the latest Bicep CLI binary
    (New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")
    # Add bicep to your PATH
    $currentPath = (Get-Item -path "HKCU:\Environment").GetValue('Path', '', 'DoNotExpandEnvironmentNames')
    if (-not $currentPath.Contains("%USERPROFILE%\.bicep"))
    {
        setx PATH ($currentPath + ";%USERPROFILE%\.bicep")
    }
    if (-not $env:path.Contains($installPath))
    {
        $env:path += ";$installPath"
    }
}
# Verify you can now access the 'bicep' command.
bicep --help
# upgrade to latest version
az bicep upgrade
# Set account, if you have multiple libraries
$subId = Read-Host "Define subscription ID to use or just press enter to take the default set (press ENTER)"
if ($subId -ne "")
{
    az account set -s $subId
}
subscriptionId=$( az account show --query id --output tsv )
Write-Host "installing required provider and extensions for the exercise - or updating if already enabled / installed"
# add modules to have them installed
az extension add --name containerapp --upgrade
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights

$name = Read-Host "Put in the name for the service principal - needs to be unique - if empty, we will generate random name"
if ($name -eq "")
{
    Write-Host "No name was specified, generating random name"
    # https://devblogs.microsoft.com/scripting/generate-random-letters-with-powershell/
    $name = (-join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_}))
    Write-Host "Default name for service principal is " + $name
}
$spJson = az ad sp create-for-rbac -n $name --role "Contributor" --scopes /subscriptions/$subscriptionId | ConvertFrom-Json
# Output should be:
#{
#  "appId": "GUID",
#  "displayName": "RANDOMNAME",
#  "password": "01n8Z~LkUGIJ0mABCe9v==D4iWwHC8aR_ABC6aqB",
#  "tenant": "GUID"
#}

Write-Host "Configuring scripts and applications to use the values for " + $name + " with ID "
 + $spJson.appId + " and setting it to ENV variables"

New-Item -Path Env:\AMA_SP_APPID -Value $spJson.appId
New-Item -Path Env:\AMA_SP_DISPLAY_NAME -Value $spJson.displayName
New-Item -Path Env:\AMA_SP_PASSWORD -Value $spJson.password
New-Item -Path Env:\AMA_SP_TENANTID -Value $spJson.tenant

$persist=Read-Host "Do you want to persist values to be stored to ENV variables? (y/n). Default is n."
if ($persist -eq "y")
{
    ## add to Powershell profile
    if (-not (Test-Path -Path $PROFILE -PathType Leaf))
    {
        # create file and add the items to the file
        New-Item -Type File $PROFILE
    }
    
    # add to the profile file
    Add-Content -Path $PROFILE -Value ("New-Item -Path Env:\AMA_SP_APPID -Value " + $spJson.appId)
    Add-Content -Path $PROFILE -Value ("New-Item -Path Env:\AMA_SP_DISPLAY_NAME -Value " + $spJson.displayName)
    Add-Content -Path $PROFILE -Value ("New-Item -Path Env:\AMA_SP_PASSWORD -Value " + $spJson.password)
    Add-Content -Path $PROFILE -Value ("New-Item -Path Env:\AMA_SP_TENANTID -Value " + $spJson.tenant)
    
    Write-Host "Added to profile to be available on launch"
}
Get-ChildItem Env:

Write-Host "Environment variables set, continue with other scripts"
