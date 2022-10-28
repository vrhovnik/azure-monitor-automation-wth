# Move to Azure and configure it effectively

<!-- TOC -->
* [Move to Azure and configure it effectively](#move-to-azure-and-configure-it-effectively)
  * [Desired Azure deployment result diagram](#desired-azure-deployment-result-diagram)
  * [Task requirement](#task-requirement)
  * [Test the functionality](#test-the-functionality)
* [Expected learnings](#expected-learnings)
* [Help links](#help-links)
* [Modernize the application](#modernize-the-application)
<!-- TOC -->

To migrate to Azure we need to understand what we have available and how to migrate to the cloud. As company CTO decided
to first move to IaaS (lift and shift) and then do optimizations on top of it. As company wants to include it into
DevOps, CTO decided to automate everything - from creation of resources in Azure, installing the software, creating web
resources, configuring database and defining connection strings / settings. To be able to replicate the same solution,
you need to make sure you have proper pipeline in place with an option to change the configuration and recreate
environment for specific customer.

You have been given [the repository](https://github.com/vrhovnik/azure-monitor-automation-wth) with all required
artifacts, which you can [fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo).

## Desired Azure deployment result diagram

CTO (together with cloud solution architect) built required simple diagram to demonstrate what we need to establish with
DevOps pipeline.

![IaaS solution](https://webeudatastorage.blob.core.windows.net/web/AzureIaaS.png)

## Task requirement

Your job is to create (without user intervention) DevOps pipeline to deploy application to desired customer:

1. resources in Azure defined in upper diagram - customer should have his virtual machine with all required software
   deployed to resource group named **rg-customername**
2. upon VM creation install required software **automatically** with provided
   script [here](https://go.azuredemos.net/ama-initial-script)
3. deploy workloads and expose them to internet (port 443 and 80) via FQDN prefix **customername-wth-europe**
4. make sure deployment fires when you push (and approve) to the folder [IaC](../scripts/IaC) - if you update the
   folder, **ALL** customer needs to be updated. Provide a way to **manually** update specific customer.
5. provide a way to deploy solution **ONLY** if validation of resource creation pass.
6. execute health report to see if the solution is responding with 200 OK (calling get request FQDN/health will give you
   information about health status)

Script to install the software is available below:

``` powershell
Invoke-WebRequest https://go.azuredemos.net/ama-01-softwaree-install -o setup.ps1
```

It is recommended to test the script before execution. Create Azure Virtual Machine manually, connect to machine,
execute upper line in Windows PowerShell to get the script and invoke the script:

``` powershell
./setup.ps1
```

## Test the functionality

After creating the resources automatically you will get FQDN (prefix **customername-wth-europe**). You can test the
solution as well with IP to see, if it
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

# Expected learnings

On this challenge you'll learn along the way about:

1. different ways to create environments (Terraform, Bicep, ... ) and scope it to appropriate resource level creation
   model
2. execute scripts after resources are created to prepare environments with different techniques: how to load scripts at
   logon or how to execute them one by one (one main script which calls other when needed)
3. leverage bash, PowerShell, Azure CLI to adapt based on installed environment
4. prepare scripts in a way that can be reusable later
5. integrate IaC into Devops pipeline and configure environment to have deployable solution available for all or
   specific customer

# Help links

To help with your challenge some helper links below:

1. [Github Fork Repo](https://docs.github.com/en/get-started/quickstart/fork-a-repo)
2. [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/managing-a-branch-protection-rule)
3. [Public IP DNS label](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#dns-name-label)
4. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/)
5. [Azure Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep)
6. [Chocolatey](https://chocolatey.org/)
7. [Dotnet Publish](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-publish)
8. [Start-Process PowerShell](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-process?view=powershell-7.2)

# Modernize the application

With rising solution and an ability to run hybrid workloads, you were asked to take advantage of containers and
modernize the app to embrace cloud native approach.

[<< Application structure](./00-init.md) | [Modernize the application >>](./03-modernization-in-Azure.md)