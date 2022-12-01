# Monitoring pre-requisites

<!-- TOC -->
* [Monitoring pre-requisites](#monitoring-pre-requisites)
  * [Before you start](#before-you-start)
    * [Your local machine](#your-local-machine)
      * [Step by step](#step-by-step)
      * [Using one script to install and prepare everything](#using-one-script-to-install-and-prepare-everything)
    * [Azure Shell](#azure-shell)
  * [Deploy VM with solution](#deploy-vm-with-solution)
  * [Container app deployment](#container-app-deployment)
* [Final result](#final-result)
* [Additional information and links](#additional-information-and-links)
* [Navigate back to main page](#navigate-back-to-main-page)
<!-- TOC -->

If you don't have VM and container deployed or you deleted everything from first three challenges, you can use the
following scripts to set them up from scratch to get up and running.

You will need 2 things to be able to complete the challenges:

1. deploy VM with solution and SQL server on VM - [Deploy VM with solution](#deploy-vm-with-solution)
2. deploy container app with SQL, images and registry - [Container app deployment](#container-app-deployment)

I prepared set of scripts to help you set up everything automagically. You can use step by step or run the script below.

## Before you start

You will need to have Azure subscription to continue. As you will be creating resources and adding permissions to
resources, you need to have [owner access](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner).

### Your local machine

If you already have **az cli** and **bicep** installed, you can skip Before section. You will need to download the
artifacts though:

1. either clone it - **git clone https://github.com/vrhovnik/azure-monitor-automation-wth** - or
2. download [zip from here](https://github.com/vrhovnik/azure-monitor-automation-wth/archive/refs/heads/main.zip),
   extract it to folder and navigate to **root/scripts/IaC**

You can then navigate navigate directly to [Deploy VM with solution](#deploy-vm-with-solution)
and [Container app deployment](#container-app-deployment).

#### Step by step

**Disclamer**: **check** the scripts before you run them.

1. Run PowerShell (you can install it
   from [here](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.3)
   if you want the latest and greatest)
2. To run the scripts you will need to have az cli installed and an active Azure subscription - run
   script [here](../scripts/PWSH/PreReqs/00-install.ps1). If you rather work with with service principal to login, you
   can look at this script [here](../scripts/PWSH/PreReqs/01-az-and-bicep-configuration.ps1). Please note, it will add
   sp details to env variables and save it to PowerShell profile.
3. Install bicep in az cli - run script [here](../scripts/PWSH/bicep-install.ps1)
4. Clone the repo (**git clone https://github.com/vrhovnik/azure-monitor-automation-wth**) - you will need to
   have [git](https://git-scm.com/) installed. If you don't want that, you can
   download [zip from here](https://github.com/vrhovnik/azure-monitor-automation-wth/archive/refs/heads/main.zip) and
   extract it to your location.
5. When cloned (or extracted), navigate to folder (**ROOT/scripts/IaC**). VM folder contains bicep files and scripts to
   deploy VM with solution. Modernization folder contains bicep files and scripts to deploy container app with SQL,
   images and
   registry, container app.

#### Using one script to install and prepare everything

Execute this script to automate the steps above:

```powershell

(New-Object Net.WebClient).DownloadFile("https://raw.githubusercontent.com/vrhovnik/azure-monitor-automation-wth/main/scripts/PWSH/PreReqs/00-oneliner.ps1", "$env:TEMP\00-oneliner.ps1")
& "$env:TEMP\00-oneliner.ps1"

```

You will see folder **amaw\azure-monitor-automation-wth-main** created in your home directory. Navigate to that folder
and then into subfolder **ROOT\scripts\IaC**.

**Example**: C:\Users\yourusername\amaw\azure-monitor-automation-wth-main\scripts\IaC

### Azure Shell

Azure Shell has all of the tools preinstalled. You can use it to run the scripts below.

1. Navigate to [Azure Portal](https://portal.azure.com)
2. Open Shell in upper corner or use [https://shell.azure.com/](https://shell.azure.com/). If you don't have storage
   assigned, create it. Choose either bash or PowerShell. PowerShell is **recommended**.
3. Clone the repo (**git clone https://github.com/vrhovnik/azure-monitor-automation-wth**)
4. Navigate to folder (**cd azure-monitor-automation-wth/scripts/IaC**). VM folder contains bicep files and scripts to
   deploy VM with solution. Modernization folder contains bicep files and scripts to deploy container app with SQL,
   images and
   registry, container app.

**NOTE**: VM solution opens RDP on local machine. As you are using Azure Shell, you are virtualized via browser. You
will get IP back in cli output. Open RDP on your
machine (search for Remote Desktop Connection) and enter received IP. The same will be with container app deployment.
Script executes edge with url to open url. In Azure Shell that is not possible, so you can copy link from cli output and
open it in a browser.

## Deploy VM with solution

To deploy the VM, you can leverage the following [script](../scripts/IaC/VM/azure-creation.ps1) which does the
following:

1. Create or update the resource group
2. Create or update VM
3. Opens Remote Connection to connect into VM

**Note:** you will find the script in **ROOT/scripts/IaC/VM** folder. Navigate to that folder.

It takes 6 parameters (or you can use default values where applicable):

1. **regionToDeploy** -- resource group location (most common is westeurope)
2. **rgName** -- name of the resource group (it will be created or updated)
3. **vmName** -- name of the VM (it will be created or updated)
3. **adminName** -- username name for VM to RDP into
4. **adminPass** -- password for user to RDP into
5. **workDir** - directory where you cloned your solution f.e. "C:/Work/Projects/azure-monitor-automation-wth",

```powershell

.\azure-creation.ps1 -regionToDeploy "westeurope" -vmName "vm-ama-customer" -rgName "rg-automation-wth" -workDir "C:/Work/Projects/azure-monitor-automation-wth" -adminName "admin" -adminPass "P@ssw0rd"

``` 

After running the solution, you should see the RDP dialog with (newly) created (or updated) IP connecting to the VM.

Connect to machine with provided username and password. You should see installation process to kick (script is
available [here](https://raw.githubusercontent.com/vrhovnik/azure-monitor-automation-wth/main/scripts/PWSH/00-Move%20to%20IaaS/02-web-db-install.ps1))
in and preparing the environment:

1. installing SQL Express on the VM
2. downloading source code, creating IIS site and configuring it
3. creating database and tables and populate it with data
4. configure connection string for the application and updating application settings automatically

Test out the solution by navigating to the **http://localhost/ttaweb/Tasks** inside virtual machine. If you see the
application running (exception seen is fine), close the RDP and connect via created FQDN or IP via browser by appending
ttaweb virtual url.

**Example**: https://[your defined DNS].westeurope.cloudapp.azure.com/ttaweb/Tasks

## Container app deployment

Container app should be deployed in the same resource group as the VM. For clean install, define new resource group as a
parameter. The same resource group will enable you to delete everything in one go.

To deploy container app with private registry, this is the [script](../scripts/IaC/Modernization/azure-creation.ps1)
which will do the following:

1. Create or update the resource group
2. Create or update Azure Container Registry
3. Builds and deploy container images to registry
4. Create SQL, adds firewall rules and creates database
5. Imports existing data to SQL, prepares connection string for the application to be used later
6. Creates (or updates) application insights, prepares connection strings for the app
7. Create container app with latest image from registry

**Note:** you will find the script in **ROOT/scripts/IaC/Modernization** folder. Navigate to that folder and then
execute script below.

It takes 6 parameters (or you can use default values where applicable):

1. **regionToDeploy** -- resource group location (most common is westeurope)
2. **rgName** -- name of the resource group (it will be created or updated)
3. **workDir** - directory where you cloned your solution f.e. "C:/Work/Projects/azure-monitor-automation-wth",
4. **acrName** -- name of the container registry (it will be created or updated)
5. **sqlServerName** -- name of the SQL server (it will be created or updated)
6. **sqlServerUsername** - username for SQL server
7. **sqlServerPwd** - password for SQL server
8. **containerappenv** -- name of the container environment
9. **containerapp** -- name of the container environment

_Usage_:

```powershell
.\azure-creation.ps1 -regionToDeploy "westeurope" -rgName "rg-automation-wth" -workDir "C:/Work/Projects/azure-monitor-automation-wth" -acrName "acrautomationwth" -containerappenv "containerappenv" -containerapp "containerapp" -sqlServerName "sqlserver" -sqlServerUsername "ttadmin" -sqlServerPwd "P@ssw0rd"
```

Don't worry if you will get any exceptions. We will monitor them later on in the hack to get information about what is
happening.

# Final result

When completed, you should have the following resources deployed:

![Monitor pre-reqs](https://webeudatastorage.blob.core.windows.net/web/Monitoring-pre-req-result.png)

# Additional information and links

1. [PowerShell](https://learn.microsoft.com/en-us/PowerShell/)
2. [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/)
3. [Create VM with IIS](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-cli)
4. [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/overview)

# Navigate back to [main page](../README.md)

[Back to Enable Monitoring](./03-modernization-in-Azure.md) | [Back to the challenges](./00-challenges.md)
