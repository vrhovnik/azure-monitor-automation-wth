# Move to Azure

<!-- TOC -->

* [Move to Azure](#move-to-azure)
    * [Required diagram](#required-diagram)
* [Task requirement](#task-requirement)
* [Test the functionality](#test-the-functionality)
* [Help links](#help-links)

<!-- TOC -->

To migrate to Azure we need to understand what we have available and how to migrate to the cloud. As company CTO decided
to first move to IaaS (lift and shift) and then do optimizations on top of it. As company wants to include it into
DevOps, CTO decided to automate everything - from creation of resources in Azure, installing the software, creating web
resources, configuring database and defining connection strings / settings.

## Required diagram

CTO (together with cloud solution architect) built required simple diagram to mimic what we need to establish:

![IaaS solution](https://webeudatastorage.blob.core.windows.net/web/AzureIaaS.png)

# Task requirement

Your job is to create (without user intervention):

1. resources in Azure defined in upper diagram
2. install software automatically
3. deploy applications to web applications and expose them to internet (port 443 and 80)
4. configure connection string for application to be working with configured database
5. prepare and configure FQDN to access the solution

To ease up the task, DevOps team provided you with script to install all necessary software on newly created machine:

``` powershell
Invoke-WebRequest https://go.azuredemos.net/ama-01-softwaree-install -o setup.ps1
```

It is recommended to test the script before execution. Create VM, execute upper line and invoke the script:

``` powershell
./setup.ps1
```

# Test the functionality

After creating the resources automatically, you will get FQDN. You can test the solution as well with IP to see, if it
works both ways.

Open a browser and navigate to FQDN and test the website and REST client.

You can also use PowerShell to open webpage with default browser:

``` powershell
Start-Process https://[IP]
```

or

``` powershell
Start-Process https://[FQDN]
```

# Help links

To help with your challenge some helper links below:

1. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/)
2. [Azure Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep)
2. [Chocolatey](https://chocolatey.org/)
3. [Dotnet Publish](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-publish)
4. [Start-Process PowerShell](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-process?view=powershell-7.2)

[<< Description of the task](./00-init.md) | [Scale out >>](./02-Scale-Solution.md)