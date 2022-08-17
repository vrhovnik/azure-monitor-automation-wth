# 
.SYNOPSIS
TTA PowerShell script to setup web application to be installed on VM

.DESCRIPTION
installs all neccessary file to be installed on VM with getting back address to be able to access it

.NOTES
Author      : Bojan Vrhovnik
GitHub      : https://github.com/vrhovnik
Version 0.0.1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"

# you will be installing web app inside IIS 
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}
