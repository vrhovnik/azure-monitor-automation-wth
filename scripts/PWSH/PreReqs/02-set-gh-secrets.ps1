## install module for PowerShell
## more info on https://github.com/microsoft/PowerShellForGitHub
# Install-Module -Name PowerShellForGitHub -Force

# install GH tools
Invoke-WebRequest -Uri "https://github.com/cli/cli/releases/download/v2.19.0/gh_2.19.0_windows_amd64.msi" -OutFile .\gh.msi
Start-Process msiexec.exe gh.msi -Wait -ArgumentList '/I gh.msi /quiet'
# remove the installer
Remove-Item .\gh.msi
# restart the shell (if you are in Windows Terminal, this will open new window)
Invoke-Command { & "powershell.exe" } -NoNewScope
# if using PowerShell 7, then use this command
# Invoke-Command { & "pwsh.exe" } -NoNewScope

# login to GH (you can also use gh auth login --with-token < mytoken.txt - to create token you can use)
gh auth login

# fork the repository https://cli.github.com/manual/gh_repo_fork
gh repo fork "https://github.com/vrhovnik/azure-monitor-automation-wth" --clone=true --remote=true

# create new secrets (if you created steps in the previous scripts)
# https://docs.github.com/en/rest/reference/actions#create-or-update-a-repository-secret
#Env:\AMA_SP_AZURE_CREDS 
#Env:\AMA_SP_APPID 
#Env:\AMA_SP_PASSWORD
#Env:\AMA_SP_TENANTID
gh secret set AMA_SP_AZURE_CREDS -b $Env:AMA_SP_AZURE_CREDS
gh secret set AMA_SP_APPID -b $Env:AMA_SP_APPID
gh secret set AMA_SP_PASSWORD -b $Env:AMA_SP_PASSWORD
gh secret set AMA_SP_TENANTID -b $Env:AMA_SP_TENANTID

