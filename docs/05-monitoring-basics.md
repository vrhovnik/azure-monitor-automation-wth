# Monitoring basics

<!-- TOC -->
* [Monitoring basics](#monitoring-basics)
  * [Pre-requisites](#pre-requisites)
    * [Deploy VM with solution](#deploy-vm-with-solution)
    * [Container app deployment](#container-app-deployment)
  * [Task requirement](#task-requirement)
  * [Test the functionality](#test-the-functionality)
* [Expected learnings](#expected-learnings)
* [Useful links](#useful-links)
<!-- TOC -->

Solution is now up and running. Some customers saw challenges with random errors or application not to anything.
Go and enable monitoring to understand what is happening with the application and to mitigate the errors. Customers
provided few screenshots and information about the errors.

## Pre-requisites

By finishing first two challenges you _should_ have at least 1 VM with solution and 1 container app up and running. 
If you see the skipped them, you can deploy them now by using selected option. 

If you don't have it deployed or you deleted everything from before, you can use the following scripts to set them up from scratch:
1. deploy VM with solution and SQL server on VM  
2. deploy container app with SQL, images and registry

If you don't have all the tools on your machine installed, you can use the following script to install them:
1. install az cli and login - [here](../scripts/PWSH/PreReqs/00-install.ps1)
2. install all of the tools and configure IIS via chocolatey - [here](../scripts/PWSH/PreReqs/00-install-tools.ps1)
3. install bicep, configure subscription (add providers, extensions,...), create access and store them to env variables -  - [here](../scripts/PWSH/PreReqs/01-az-and-bicep-configuration.ps1)
4. fork and clone repo and store secrets to GitHub to have it available for the DevOps cycle - [here](../scripts/PWSH/PreReqs/02-set-gh-secrets.ps1)

or use [Azure Shell](https://shell.azure.com). You will need to clone the repo (**git clone https://github.com/vrhovnik/azure-monitor-automation-wth**) to access all of the artifacts.

When cloned, navigate to folder (ROOT/scripts/IaC). VM folder contains bicep files and scripts to deploy VM with solution. 
Modernization folder contains bicep files and scripts to deploy container app with SQL, images and registry, container app.

### Deploy VM with solution

To deploy the VM, you can leverage the following [script](../scripts/IaC/VM/azure-creation.ps1):

1. Create or update the resource group
2. Create or update VM
3. Opens Remote Connection to connect into VM

It takes 6 parameters (or you can use default values where applicable):
1. **regionToDeploy** -- resource group location (most common is westeurope)
2. **rgName** -- name of the resource group (it will be created or updated)
3. **adminName** -- username name for VM to RDP into
4. **adminPass** -- password for user to RDP into
5. **workDir** - directory where you cloned your solution f.e. "C:/Work/Projects/azure-monitor-automation-wth",

```powershell

.\azure-creation.ps1 -regionToDeploy "westeurope" -rgName "rg-automation-wth" -workDir "C:/Work/Projects/azure-monitor-automation-wth" -adminName "admin" -adminPass "P@ssw0rd"

``` 

After running the solution, you should see the RDP dialog with (newly) created (or updated) IP connecting to the VM.

### Container app deployment 

Container app can be deployed in the same resource group as the VM. For clean install, define new resource group as a parameter.

To deploy container app this is the [script](../scripts/IaC/Modernization/azure-creation.ps1) which will do the following:
1. Create or update the resource group
2. Create or update registry
3. Builds and deploy container images to registry
4. Create SQL, adds firewall rules and creates database
5. Imports existing data to SQL, prepares connection string to be used later
6. Create or update container app with latest image from registry

It takes 6 parameters (or you can use default values where applicable):
1. **regionToDeploy** -- resource group location (most common is westeurope)
2. **rgName** -- name of the resource group (it will be created or updated)
3. **workDir** - directory where you cloned your solution f.e. "C:/Work/Projects/azure-monitor-automation-wth",
4. **acrName** -- name of the container registry (it will be created or updated)
5. **containerappenv** -- name of the container environment
6. **containerapp** -- name of the container environment

_Usage_: 

```powershell
.\azure-creation.ps1 -regionToDeploy "westeurope" -rgName "rg-automation-wth" -workDir "C:/Work/Projects/azure-monitor-automation-wth" -acrName "acrautomationwth" -containerappenv "containerappenv" -containerapp "containerapp"
```

## Task requirement

1. Enable monitoring on all of the customer solutions you have in Azure - infrastructure and application 
2. Provide a script (jMeter, PowerShell, Bash, ...) to generate some load on the application to test out functionality
3. [OPTIONAL] add script to DevOps process to generate load on the application via CI/CD pipeline after deployment has succeeded with codeowner approval
4. monitor load and after receiving more than 10% load, scale the affected application by 1 instance automatically
5. find the errors in the application and create an alert to notify users about the errors by using emails 

## Test the functionality

1. Generate load on the application and monitor via Azure Monitor how the application is performing
2. Scale the application automatically when load is more than 10% - going up
3. When error occurs, demonstrate how the alert is triggered and how the notification is sent to appropriate users

# Expected learnings

1. Understand how to enable monitoring in Azure for different type of solutions
2. Understand how to use Azure Monitor to monitor the application
3. Understand how to use Azure Monitor to monitor the infrastructure 
4. Use mechanisms from Azure Monitor to notify and react to the errors 
5. Leverage built-in mechanisms to scale the application automatically 

# Useful links

1. [Azure Monitor overview](https://learn.microsoft.com/en-us/azure/azure-monitor/monitor-reference)
2. [Azure Load Testing](https://learn.microsoft.com/en-us/azure/load-testing/overview-what-is-azure-load-testing)
3. [jMeter](https://jmeter.apache.org/) 
3. [Bombardier benchmarking tool](https://github.com/codesenberg/bombardier) 

[<< Enable Monitoring](./03-modernization-in-Azure.md) | [<< Back to the challenges](./00-challenges.md)
| [Monitoring previews >>](./06-monitoring-previews.md)  