# Azure Automation & Monitor What The Hack

<!-- TOC -->

* [Azure Automation & Monitor What The Hack](#azure-automation--monitor-what-the-hack)
    * [Version **TL;DR;**](#version-tldr)
    * [Tech pre-requisites](#tech-pre-requisites)
    * [Knowledge expected](#knowledge-expected)
    * [Knowledge gains](#knowledge-gains)
* [Start solving challenges to go from zero to hero](#start-solving-challenges-to-go-from-zero-to-hero)
* [Repository and code structure](#repository-and-code-structure)
    * [Source code - src folder](#source-code---src-folder)
    * [Containers overview](#containers-overview)
    * [Scripts folder overview](#scripts-folder-overview)
* [Additional information](#additional-information)
* [Credits](#credits)
* [Contributing](#contributing)

<!-- TOC -->

What the hack structure initiative to enable partners to understand automation and monitoring options
in [Azure](https://portal.azure.com) through
different tools and mechanisms solving challenges, which will help them understand their application and workloads even
better. Leveraging [automation](https://docs.microsoft.com/en-us/azure/automation/) to bring application in production
with ease and when having solution in production,
[monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/overview) the workload to increase the SLA for your
customers.

Learn and configure:

1. Automating deployments and practicing **DevOps** principles going from on-premise to the cloud with modernization in
   mind
2. Detect and diagnose issues across applications and dependencies with Application Insights.
3. Correlate infrastructure issues with **VM insights** and **Container insights**.
4. Drill into your monitoring data with **Log Analytics** for troubleshooting and deep diagnostics.
5. Support operations **at scale** with automated actions.
6. Create visualizations with **Azure dashboards** and **workbooks**.
7. Collect data from monitored resources by using **Azure Monitor Metrics**.
8. Investigate change data for routine monitoring or for triaging incidents by using Change Analysis.

We will work on an app for tracking your work tasks (and make some of them public with an ability for users to provide
feedback) protected by forms authentication (classic approach), backed by Microsoft SQL and exposed through REST API
services. The code is written in [.NET 6](https://dot.net). We do recommend reading about the
application [structure](#structure) before starting with challenges.

## Version **TL;DR;**

We want to use latest and greatest techniques to bring the solution from zero to hero using infrastructure as code
approach with DevOps principles in mind.

Going from this on premise (or in IaaS)

![on premise app](https://webeudatastorage.blob.core.windows.net/web/OnPremArchitecture.png)

to this in the cloud step by step

![Required environment](https://webeudatastorage.blob.core.windows.net/web/ama-container-app-basic-info.png)

## Tech pre-requisites

To successfully participate in this hackathon you will need:

1. an active [Azure](https://www.azure.com) subscription - [MSDN](https://my.visualstudio.com) or trial
   or [Azure Pass](https://microsoftazurepass.com) is fine - you can also do all of the work
   in [Azure Shell](https://shell.azure.com) (all tools installed) and by
   using [Github Codespaces](https://docs.github.com/en/codespaces/developing-in-codespaces/creating-a-codespace)
2. [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) installed to work with Azure
3. [GitHub](https://github.com/) account (sign-in or join [here](https://github.com/join)) - how to authenticate with
   GitHub
   available [here](https://docs.github.com/en/get-started/quickstart/set-up-git#authenticating-with-github-from-git)
4. [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2)
   installed - we do recommend an editor like [Visual Studio Code](https://code.visualstudio.com) to be able to write
   scripts, YAML pipelines and connect to repos to submit changes4.
5. [OPTIONAL] [Github GUI App](https://desktop.github.com/) for managing changes and work
   on [forked](https://docs.github.com/en/get-started/quickstart/fork-a-repo) repo
6. [OPTIONAL] Windows Terminal

If you will be working on your local machines, you will need to:

1. have [Powershell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2)
installed
2. have git installed - instructions step by step [here](https://docs.github.com/en/get-started/quickstart/set-up-git)
3. [.NET](https://dot.net) installed to run the application if you want to run it
4. [SQL server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) to install the database and to populate
   it with data
5. an editor (besides notepad) to see and work with code, yaml, scripts and
   more ([Visual Studio Code](https://code.visualstudio.com), but any other editor will work as well)

## Knowledge expected

Some of the components requires from you basic understanding of:

1. Azure - learning path is available [here](https://learn.microsoft.com/en-us/training/azure/)
    - [certifications](https://learn.microsoft.com/en-us/certifications/browse/?resource_type=certification&products=azure%2Csql-server%2Cwindows-server&type=fundamentals%2Crole-based%2Cspecialty&expanded=azure%2Cwindows)
      like AZ 900 can help
2. [Git](https://git-scm.com/book/en/v2) to understand how to clone, fork, branch, merge, rebase, etc.
3. [scripting](https://en.wikipedia.org/wiki/Scripting_language#Examples) -
   either [PowerShell](https://en.wikipedia.org/wiki/PowerShell)
   or [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) (if you will decide to go this path)
3. [YAML structure](https://en.wikipedia.org/wiki/YAML) to be able to complete pipelines and workflows

## Knowledge gains

By completing the hackathon you'll understand how to:

1. use IaC effectively with DevOps principles
2. configure scale and deploy with ease with solid foundation
3. leverage technologies to deploy native workloads to cloud
4. effectively react on challenges and take advantage of cloud to build resilient environment for workloads
5. define visuals for technical and non-technical people to gain insight into workloads and services

# Start solving challenges to go from zero to hero

Too start the mini hackathon click button below:

[![button](https://webeudatastorage.blob.core.windows.net/files/start-challenges.jpg)](./docs/00-init.md)

# Repository and code structure

Solution has 4 main folders:

1. **src** - solution source code based on C#, [ASP.NET](https://asp.net) Core, [htmx](https://htmx.org)
   , [Bootstrap](https://getbootstrap.com) and many more.
2. **scripts** - PowerShell scripts, ARM templates and Bicep language to automate deployments, multi-tenancy and
   monitoring
3. **docs** - documentation, architecture diagrams, videos and many more
4. **containers** - docker files to generate below applications for modernization options

## Source code - src folder

Solution is built out of 5 main parts:

![source code overview](https://webeudatastorage.blob.core.windows.net/web/tta-src-overview.png)

1. **TTA.Web** - web client to manage tasks, see public open tasks, register into the system, view statistics and work
   with your tasks
2. **TTA.Web.ClientApi** - REST api to expose services to get tasks and operate on them
3. Clients applications
    - **TTA.Client.Win** - Windows client to check tasks, complete them and add comments and to simulate comments
    - **TTA.DataGenerator.SQL** - console application to recreate database and populate data
4. **TTA.StatGenerator** - worker service to calculate stats and populate data daily
5. **TTA.SQL** - MS SQL data storage implementation

All other projects are meant for helpers and for core infrastructure needs for application to be able to work.

1. **TTA.Core** - helpful classes to generate password hash, extensions for strings and so more
2. **TTA.Interfaces** - interfaces to be used in the application
3. **TTA.Models** - models representing the solution

To compile and run the code you will need [.NET core installed](https://dot.net). To work with the source code, you have
multiple editors available ([Microsoft Visual Studio](https://visualstudio.com)
, [Microsoft Visual Studio Code with C#](https://code.visualstudio.com)
plugin, [Jetbrains Rider](https://jetbrains.com/rider) and more).

## Containers overview

To take advantage of modernization opportunity and make solution to be cloud native aware, below are the container
files:

1. [TTA.Web.dockerfile](containers/TTA.Web.dockerfile) - instructions to compile and build container with web
   application
2. [TTA.Web.ClientApi.dockerfile](containers/TTA.Web.ClientApi.dockerfile) - instructions to compile and build container
   containing REST APIs
3. [TTA.DataGenerator.SQL.dockerfile](containers/TTA.DataGenerator.SQL.dockerfile) - container with generator to be used
   with container instances to generate SQL data
4. [TTA.StatGenerator](containers/TTA.StatGenerator.dockerfile) - background process as container to generate stats
   based on [cron](https://en.wikipedia.org/wiki/Cron) expression definition

You can leverage [Docker](https://docker.com), [Podman](https://podman.io)
or [Azure Container Registry to build](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-quick-task)
the containers.

To use Azure Container registry cloud build, you can execute following command from src folder (if you
have [az cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed):

`az acr build --image tta/web:1.0 --registry ##yourregistryname## --file ../containers/TTA.Web.dockerfile .`

`az acr build --image tta/webclient:1.0 --registry ##yourregistryname## --file ../containers/TTA.Web.ClientApi.dockerfile .`

`az acr build --image tta/statgen:1.0 --registry ##yourregistryname## --file ../containers/TTA.StatGenerator.dockerfile .`

`az acr build --image tta/datagen:1.0 --registry ##yourregistryname## --file ../containers/TTA.DataGenerator.SQL.dockerfile .`

## Scripts folder overview

Scripts contains folders with scripts for specific purposes in mixed languages (bash, pwsh, bicep, terraform,...).

For example: SQL folder contains scripts to create all tables or
separate table - depends on the need in specific.

Keep in mind - there are multiple ways to complete specific task and the idea is to learn new technology, not copy and
paste solutions.

# Additional information

You can read about different techniques and options here:

1. [What-The-Hack initiative](https://aka.ms/wth)
2. [Azure Samples](https://github.com/Azure-Samples)
   or [use code browser](https://docs.microsoft.com/en-us/samples/browse/?products=azure)
3. [Azure Architecture Center](https://docs.microsoft.com/en-us/azure/architecture/)
4. [Application Architecture Guide](https://docs.microsoft.com/en-us/azure/architecture/guide/)
5. [Cloud Adoption Framework](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/)
6. [Well-Architected Framework](https://docs.microsoft.com/en-us/azure/architecture/framework/)
7. [Microsoft Learn](https://docs.microsoft.com/en-us/learn/roles/solutions-architect)

# Credits

1. [Spectre.Console](https://spectreconsole.net/) - Spectre.Console is a .NET Standard 2.0 library that makes it easier
   to create beautiful console applications.
2. [MetroApps](https://mahapps.com/) - MahApps.Metro is a framework that allows developers to cobble together a Metro or
   Modern UI for their own WPF applications with minimal effort.
3. [HTMX](https://htmx.org) - htmx gives you access to AJAX, CSS Transitions, WebSockets and Server Sent Events directly
   in HTML, using attributes, so you can build modern user interfaces with the simplicity and power of hypertext.
4. [QuestPDF](https://github.com/QuestPDF/QuestPDF) - QuestPDF is an open-source .NET library for PDF documents
   generation.
5. [Mermaid.js](https://github.com/mermaid-js/mermaid) - generating dialogs from markdown files -
   thanks [Adrian](https://github.com/snobu)

# Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
