# Modernization and usage in Azure

<!-- TOC -->
* [Modernization and usage in Azure](#modernization-and-usage-in-azure)
  * [Diagram](#diagram)
  * [Task requirements](#task-requirements)
* [Key takeaways](#key-takeaways)
* [Help links](#help-links)
* [Govern the application and make sure your SLA meets the goal](#govern-the-application-and-make-sure-your-sla-meets-the-goal)
<!-- TOC -->

CTO decided to move application to containers to easily scale components independently. Customers are looking for a
solution to simplify the deployment, versioning and much more. To comply with changes and after review of technology
trends CTO decided to go with latest options in Azure.

## Diagram

Cloud Solution Architects decided based
on [best practices](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/) to move to containers to support
ease of migration and usage in different environments. Developer team prepared [dockerfiles](../containers) to enable
workload containerization. For the database the decision was to go with PaaS solution. In this
case [Azure SQL database](https://azure.microsoft.com/en-us/products/azure-sql/) (DTU edition).

![Required environment](https://webeudatastorage.blob.core.windows.net/web/ama-container-app-basic-info.png)

They also prepared populate database file (or script), which you can use for database restore to have the latest and
greatest data available.

Database file is available [here](../scripts/PWSH/03-Modernization/TTADB.bak) for download or you can leverage T-SQL
commands [here](../scripts/PWSH/03-Modernization/ttadb.sql).

## Task requirements

To satisfy the request you need to:

1. automate resource deployments and create required resources per customer - for example **rg-customername**,
   **acr-customername**, **aca-customername** etc. when changes happens in IaC folder. If you do a change, **all**
   customer resources needs to be updated.
2. automate building/pushing container images to newly created private registry (**containername:vx** where **x** is **
   unique** number) and test out the images -- dev team prepared [dockerfiles](../containers) for you to use. Deploy to
   registry **only if** the image build is successful. When changes to dockerfiles has been done, run the automation.
3. deploy new version of the application when containers are changed/new version deployed and configure access to
   external resources and staging area
4. populate database with provided backup file or scripts from database team
5. test if application works as expected - after deploy, call **URLPATHTOAPPFORCUSTOMER/health** to get back 200 OK
   status

# Key takeaways

As you can see there is a little bit more setup to get application working. You experienced:

1. how to use create registries, make containers and leverage cloud tools to automatically build the images with
   blue/green techniques
2. automate deployment of resources
3. leverage PaaS tools to provide you with common tasks to get up to speed quickly

# Help links

To help with your challenge some helper links below:

1. [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-quickstart-task-cli)
2. [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/overview)
3. [Requiring successful dependent jobs](https://docs.github.com/en/actions/using-jobs/using-jobs-in-a-workflow#example-requiring-successful-dependent-jobs)

# Govern the application and make sure your SLA meets the goal

Solution is now up and running. We tried out different options, different services. Now we need to make sure that
running solution works reliably and resilient.

[<< Move to Azure](./01-move-to-IaaS-Azure.md) | [ Make SLA great again >>](./05-monitoring-basics.md)