# Modernization and usage in Azure

<!-- TOC -->
* [Modernization and usage in Azure](#modernization-and-usage-in-azure)
  * [Diagram](#diagram)
  * [Requirements](#requirements)
* [Enable monitoring to get information](#enable-monitoring-to-get-information)
<!-- TOC -->

CTO decided to move application to containers and with that we can easily scale components independently.

## Diagram

Cloud Solution Architects decided based
on [best practices](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/) to move to containers to support
ease of migration and usage in different environments. To easily support the move, developer team
prepared [dockerfiles](../containers) to prepare the images.

## Requirements

To satisfy the request you need to:
1. prepare containers and test out the images (dev team prepared [dockerfiles](../containers) to support the preparation)
2. automate resource deployment / image creation and create an ability to scale quickly
3. deploy applications based on inputted parameters 

# Enable monitoring to get information

Solution is now up and running. Some customers saw challenges with random errors or application not to anything. 
Go and enable monitoring to understand what is happening with the application and to mitigate the errors.

[<< Modernization approach](./03-modernization-in-Azure.md)) | [ Enable Monitor >>](./04-monitoring-basics.md)