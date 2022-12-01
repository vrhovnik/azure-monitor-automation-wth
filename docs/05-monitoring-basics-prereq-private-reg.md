# Deploy container apps with public registry - not automated

If you don't want to use private registry, you can use [public one from Docker Hub](https://hub.docker.com/u/bvrhovnik).
But to do so, you will need to deploy it manually.

Prebuild container images are available here:

1. web interface - available [here](https://hub.docker.com/repository/docker/bvrhovnik/ttaweb)
2. web REST - available [here](https://hub.docker.com/repository/docker/bvrhovnik/ttawebclient)
3. SQL generator - available [here](https://hub.docker.com/repository/docker/bvrhovnik/ttasql)
4. Stat Generator - available [here](https://hub.docker.com/repository/docker/bvrhovnik/ttastatgen)

Before you deploy the container app, you need to create SQL database and import data. You can use
the [following tutorial](https://learn.microsoft.com/en-us/azure/azure-sql/database/single-database-create-quickstart?view=azuresql&tabs=azure-portal)
to create database. Name of the database is **TTADB**.

After you create the database, you need to import data. You can use
the [following tutorial](https://docs.microsoft.com/en-us/azure/azure-sql/database/scripts/import-data-from-bacpac-portal?tabs=azure-portal)
to import data. You can use the [BACPAC file](../scripts/IaC/Modernization/TTADB.bacpac) from the repo.

When finished with SQL creation, you have step by step instructions how to deploy Azure Container App in portal,
available [here](https://learn.microsoft.com/en-us/azure/container-apps/get-started-existing-container-image-portal?pivots=container-apps-public-registry)
.

For app to be configured properly, you will need to specify connection string. You can define the connection strings
by [changing data from here](https://www.connectionstrings.com/azure-sql-database/) with your own created instances.

Then add environment variables to the container app **SqlOptions__ConnectionString** with value of the connection string
prepared earlier (when you define container details).