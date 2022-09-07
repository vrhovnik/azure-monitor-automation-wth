# Modernization and usage in Azure

<!-- TOC -->
* [Modernization and usage in Azure](#modernization-and-usage-in-azure)
  * [Diagram](#diagram)
  * [Requirements](#requirements)
* [Putting it all together](#putting-it-all-together)
<!-- TOC -->

CTO decided to move application to containers and with that we can easily scale components independently.

## Diagram

Cloud Solution Architects decided based
on [best practices](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/) to move to containers to support
ease of migration and usage in different environments. To easily support the move, developer team
prepared [dockerfiles](../containers) to prepare the images.

![Required environment](https://webeudatastorage.blob.core.windows.net/web/ama-container-app-basic-info.png)

They also prepared populate SQL image, which you can use to create data. 

## Requirements

To satisfy the request you need to:
1. prepare containers and test out the images (dev team prepared [dockerfiles](../containers) to support the preparation)
2. automate resource deployment / image creation and create an ability to scale quickly
3. deploy applications based on inputted parameters 
4. populate database with provided container from database team

# Putting it all together

Solution is now up and running. We tried out different options, different services. Now we need to make it usable across the company.
We want to enable people to create environment based on their needs and usage as part of their pipeline.

[<< Scale Solution](./02-Scale-Solution.md) | [ Putting it all together >>](./04-putting-in-all-together.md)