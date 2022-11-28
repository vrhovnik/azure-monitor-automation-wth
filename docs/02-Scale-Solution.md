# Scale solution out

<!-- TOC -->
* [Scale solution out](#scale-solution-out)
  * [Diagram](#diagram)
  * [Requirements](#requirements)
  * [Test the functionality](#test-the-functionality)
* [Expected learnings](#expected-learnings)
* [Helper links](#helper-links)
* [Modernization in the wind of change](#modernization-in-the-wind-of-change)
<!-- TOC -->

CTO is satisfied with result. After getting many traffic on the solution (and users complaining), he wants to scale out
and add resources to handle the traffic. He wants for traffic to be equally distributed and data stored in one database
for the ease of administration and control. His data team decided to move it to Azure SQL database for Azure to manage
the balancing of resources.

To prevent accidental accesses to the VM, VM needs to be private and only app is accessible from internet. If there is a
need to connect to VM, Azure Bastion should be enabled.

```mermaid
sequenceDiagram
    autonumber
    actor J as John
    participant V as VM
    J->>V: Hi V, I would like to connect
    Note over J,W: John is trying to connect to VM.
    activate W
    W->>J: Hi John, sure. This is bastion URL, connect via Azure Bastion to check me out :)
```

## Diagram

After discussing with his council, he decided to take it step by step, moving different parts out and putting solution
in front of load balancer. The image should be standard and preconfigured with required tools to be able to use it
easily. To accomodate the need to add resources automatically, he decided to automate the creation of
adding new resources to the mix. Use [IIS script](../scripts/PWSH/PreReqs/component-iis.ps1)
, [db script](../scripts/PWSH/PreReqs/component-sql.ps1)
and [.NET installation procedure](https://dotnet.microsoft.com/en-us/) to be available and preinstalled on base image.
Base image should be Windows based.

![load balancer](https://webeudatastorage.blob.core.windows.net/web/ama-LoadBalancer.png)

## Requirements

Based on the diagram above, to support automated scripts for deployment or DevOps, your job is to create:

1. resource creation automation with custom image
2. prepare an environment to have initial software preinstalled and be reusable - you can
   use [this script ](../scripts/IaC/VMMS/app-install.ps1) to install app on the servers
3. migration of existing SQL data to newly created resource (Azure SQL Basic DTU is enough for the requirement)
4. configure health probe to know if web and web REST client app is alive (ttaweb/health and ttawebclient/health to get
   back the result)
5. Check if the solution works after the change and if it redirects to different machine equally

**Bonus**: create a DevOps pipeline to add stuff via pipeline after doing a change in script.

## Test the functionality

Open a browser and navigate to that website and test functionality.

You can also use PowerShell to open webpage with default browser like this:

``` powershell
Start-Process https://[FQDN]
```

Test out both website and rest client so that they work. Run the test below to see, if random results.

# Expected learnings

On this challenge you'll learn along the way about:

1. different ways to create environments (Terraform, Bicep, ... ) and scope it to appropriate resource level creation
   model
2. execute scripts after resources are created to prepare environments with different techniques: how to load scripts at
   logon or how to execute them one by one (one main script which calls other when needed)
3. leverage bash, PowerShell, Azure CLI to adapt based on installed environment
4. prepare scripts in a way that can be reusable later and executed on machine via DSC or PWSH
5. prepare image to be reused for enviromment by using shared library

# Helper links

To help you with this quest, check out this resources:

1. [Azure SQL DTU](https://docs.microsoft.com/en-us/azure/azure-sql/database/service-tiers-dtu?view=azuresql)
2. [Azure Load Balancer](https://docs.microsoft.com/en-us/azure/load-balancer/concepts)
3. [Create and use custom image for VMSS](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/tutorial-use-custom-image-cli) or [create an image via portal](https://learn.microsoft.com/en-us/azure/virtual-machines/capture-image-portal)
4. [DotNET installation](https://dotnet.microsoft.com/en-us/)

# Modernization in the wind of change

Solution has grown quite a bit and customer are requiring new functionalities / special requirements to suit their
needs and to scale independently. To accomodate such requests, CTO decided to move application to containers and with
that we can easily scale components independently.

[<< Move to IaaS](./01-move-to-IaaS-Azure.md) | [Modernization approach >>](./03-modernization-in-Azure.md)