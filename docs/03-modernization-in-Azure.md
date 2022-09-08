# Modernization and usage in Azure

<!-- TOC -->

* [Modernization and usage in Azure](#modernization-and-usage-in-azure)
    * [Diagram](#diagram)
    * [Requirements](#requirements)
* [Putting it all together](#putting-it-all-together)

<!-- TOC -->

CTO decided to move application to containers to easily scale components independently. Customers are looking for a
solution to simplify the deployment, versioning and much more. To comply with changes and after review of technology
trends you decided to go with latest and greatest solutions.

## Diagram

Cloud Solution Architects decided based
on [best practices](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/) to move to containers to support
ease of migration and usage in different environments. To easily support the move, developer team
prepared [dockerfiles](../containers) to prepare the images.

![Required environment](https://webeudatastorage.blob.core.windows.net/web/ama-container-app-basic-info.png)

They also prepared populate database file (or script), which you can use for database restore to have the latest and greatest data
available.

Database file is available [here](../scripts/PWSH/03-Modernization/TTADB.bak) for download or use scripts [here](../scripts/PWSH/03-Modernization/ttadb.sql).

## Requirements

To satisfy the request you need to:

1. prepare containers and test out the images -- dev team prepared [dockerfiles](../containers) to support the
   preparation
2. automate resource deployment / image creation and create an ability to scale quickly - only web is currently required
   to run. For app to run you will need to configure SQL connection.
3. deploy applications based on inputted parameters
4. populate database with provided backup file or scripts from database team

# Key takeaways

As you can see there is a little bit more setup to get application working. You experienced:

1. how to create registries, make containers and leverage cloud tools to automatically build the images without you
   having the tools
2. automate deployment of resources with adding permissions and access control
3. prepare script in a way to have as little interaction as possible to include it into 

# Putting it all together

Solution is now up and running. We tried out different options, different services. Now we need to make it usable across
the company.
We want to enable people to create environment based on their needs and usage as part of their pipeline.

[<< Scale Solution](./02-Scale-Solution.md) | [ Putting it all together >>](./04-putting-in-all-together.md)