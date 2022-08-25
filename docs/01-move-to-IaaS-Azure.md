# Move to Azure

To migrate to Azure we need to understand what we have available and how to migrate to the cloud. As company CTO decided
to first move to IaaS (lift and shift) and then do optimizations on top of it. As company wants to include it into
DevOps, CTO decided to automate everything - from creation of resources in Azure, installing the software, creating web
resources, configuring database and defining connection strings / settings.

## Required diagram

CTO (together with cloud solution architect) built required simple diagram:

![IaaS solution](https://webeudatastorage.blob.core.windows.net/web/AzureIaaS.png)

# Task requirement

Your job is to create:
1. resources in Azure defined in upper diagram
2. install software automatically
3. deploy applications to web applications and expose them to internet (port 443 and 80)
4. configure connection string for application to be working on database

# Test the functionality

After creating the resources automatically, you will get public IP. 

Open a browser and navigate to that website and test functionality.

You can also use PowerShell to open webpage with default browser:

``` powershell
Start-Process https://[IP]
```

[<< Description of the task](./00-init.md) | [Scale out >>](./02-Scale-Solution.md)
