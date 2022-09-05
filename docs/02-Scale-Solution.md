# Scale solution out

<!-- TOC -->
* [Scale solution out](#scale-solution-out)
* [Diagram](#diagram)
* [Requirements](#requirements)
* [Test the functionality](#test-the-functionality)
  * [Modernization](#modernization)
<!-- TOC -->

CTO is satisfied with result. After getting many traffic on the solution, he wants to scale out and add resources to
handle the traffic. He wants for traffic to be equally distributed and data stored in one database.

# Diagram

After discussing with his council, he decided to take it step by step, moving different parts out and putting solution
in front of load balancer. To accomodate the need to add resources automatically, he decided to automate the creation of
adding new resources to the mix.

![load balancer](https://webeudatastorage.blob.core.windows.net/web/ama-LoadBalancer.png)

# Requirements

Based on the diagram above, to support automated scripts for deployment or DevOps, your job is to create:

1. resource creation automation
2. modification and adjusting configuration to support the change
3. migration of existing data to newly created resource (Azure SQL Basic DTU is enough for the requirement)
4. Modify changes to the application to use newly created resources
5. check if the solution works after the change

**Bonus**: create a DevOps pipeline to add stuff via pipeline after doing a change in code.

# Test the functionality

Open a browser and navigate to that website and test functionality.

You can also use PowerShell to open webpage with default browser:

``` powershell
Start-Process https://[FQDN]
```

## Modernization

Solution has grown quite a bit and customer are requiring new functionalities / special requirements to suit their
needs and to scale independently. To accomodate such requests, CTO decided to move application to containers and with
that we can easily scale components independently.

[<< Move to IaaS](./01-move-to-IaaS-Azure.md) | [Modernization approach >>](./03-modernization-in-Azure.md)