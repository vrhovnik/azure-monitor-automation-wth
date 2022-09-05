# Welcome to the Azure monitor automation workshop / What-The-Hack

<!-- TOC -->
* [Welcome to the Azure monitor automation workshop / What-The-Hack](#welcome-to-the-azure-monitor-automation-workshop--what-the-hack)
  * [Minimal requirements](#minimal-requirements)
  * [Diagrams overview](#diagrams-overview)
  * [Populate data and prepare data backend](#populate-data-and-prepare-data-backend)
  * [Flow with web application](#flow-with-web-application)
  * [Flow with client app](#flow-with-client-app)
  * [Run the applications](#run-the-applications)
    * [Web App](#web-app)
    * [Web API](#web-api)
    * [WPF app](#wpf-app)
* [Helper links](#helper-links)
* [Let's start - Move and automatic configuration in IaaS Azure](#lets-start---move-and-automatic-configuration-in-iaas-azure)
<!-- TOC -->

What the hack structure initiative to enable partners to understand automation and monitoring options
in [Azure](https://portal.azure.com) through
different tools and mechanisms solving challenges, which will help them understand their application and workloads even
better and to solve common challenges with [automation](https://docs.microsoft.com/en-us/azure/automation/)
and [monitoring](https://docs.microsoft.com/en-us/azure/azure-monitor/overview), including:

1. Automating deployments and practicing DevOps principles going from on-premise to the cloud with modernization in mind
2. Detect and diagnose issues across applications and dependencies with Application Insights.
3. Correlate infrastructure issues with VM insights and Container insights.
4. Drill into your monitoring data with Log Analytics for troubleshooting and deep diagnostics.
5. Support operations at scale with automated actions.
6. Create visualizations with Azure dashboards and workbooks.
7. Collect data from monitored resources by using Azure Monitor Metrics.
8. Investigate change data for routine monitoring or for triaging incidents by using Change Analysis.

We do recommend to fork the repo and work on it on separate branch.

## Minimal requirements

In order to follow along you will need:

1. [Dotnet SDK](https://dot.net)
2. [SQL server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) - LocalDB is sufficient
3. [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.2)
    - latest and greatest is the best :)
3. (Optional)[Database Tools](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) - navigate to bottom ot
   the page
4. (Optional)[Tools to work with Json](https://code.visualstudio.com)

**NOTE:**

If you install [IDE](https://en.wikipedia.org/wiki/Integrated_development_environment) (
f.e [Visual Studio](https://visualstudio.com),[JetBrains Rider](https://jetbrains.com/rider),...) you have all of those
tools already installed.

To work with Azure, you'll need:

1. [Azure Subscription](https://azure.microsoft.com/en-us/free/)
2. [AZ CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

Check out
also [Scott Hanselman blog post about prettifying prompts](https://www.hanselman.com/blog/how-to-make-a-pretty-prompt-in-windows-terminal-with-powerline-nerd-fonts-cascadia-code-wsl-and-ohmyposh)
to make terminals pretty.

## Diagrams overview

In order to start with the hackathon, let us check architecture diagram and requirement from the company TTA.
Your job, if you decide to accept it, is to use best practices from Microsoft to deploy and manage the solution for the
TTA company.

We have the following application on-premise:

![on premise app](https://webeudatastorage.blob.core.windows.net/web/OnPremArchitecture.png)

User can choose from various options to access functionalities, either web browser application or WPF application, which
connects to API backend via REST calls.

## Populate data and prepare data backend

To start easier with the solution, development team built SQL generator, which generates database, tables, relationship
between them and makes sure to populate data.

To give you more options, you got following options as environment variables to control how to generate and populate
data:

| Parameters            | Description                                                                           | Is mandatory                               |
|-----------------------|---------------------------------------------------------------------------------------|--------------------------------------------|
| SQL_CONNECTION_STRING | connection string to the database or data server                                      | NO (it will use LocalDB by default)        |
| FOLDER_ROOT           | root path to this solution (git clone and give root path)                             | NO (if not provided, you will be prompted) |
| DROP_DATABASE         | flag true or false to drop database                                                   | NO (if not provided, you will be prompted) |
| CREATE_TABLES         | flag true or false to create table. You can false, if you want to just populate data. | NO (if not provided, you will be prompted) |
| DEFAULT_PASSWORD      | define password. Password will be hashed.                                             | NO (if not provided, you will be prompted) |
| RECORD_NUMBER         | define number of records to be inserted                                               | NO (if not provided, you will be prompted) |

Check [TTA.DataGenerator.SQL](../src/TTASLN/TTA.DataGenerator.SQL/Program.cs) for more details about automatic data
creation.

![SQL generator sample](https://webeudatastorage.blob.core.windows.net/files/maw-sql-generator.gif "SQL generator sample")

if you want you can download video in better quality, it is
available [here](https://webeudatastorage.blob.core.windows.net/files/maw-sql-generator.mp4).

To run the solution, navigate to the [folder in terminal](../src/TTASLN/TTA.DataGenerator.SQL/)) and run dotnet run

```
dotnet run
```

## Flow with web application

User navigates to the main web page on localhost. He opens preferred web browser, goes to **https://localhost/ttaweb**
and below
flow happens:

```mermaid
sequenceDiagram
    autonumber
    actor J as John
    participant W as Web
    J->>W: Hi Web, what can I do
    Note over J,W: John is not signed in.
    activate W
    W->>J: Hi John, you are not signed in. You can search for public data - tasks flagged IsPublic=true.
```

Since John is not logged in, he can see public data - something like this:
![MAW public access](https://webeudatastorage.blob.core.windows.net/files/maw-public-access.png)

If he is logged in, he can then go to his dashboard, see his work tasks, comments, search through items, complete the,
download them as PDF, etc.

```mermaid
sequenceDiagram
    autonumber
    actor J as John
    participant W as Web
    J->>W: Hi Web, I want to login to work with my data
    Note over J,W: John is not signed in.
    activate W
    W->>J: Hi John, sure. I don't have your login information, redirecting to login page.
    deactivate W
    J->>W: Hi Web. This are my credentials.
    activate W
    W->>J: Let me check and if correct, I will redirect you to your requested url or default, if none specified.
    deactivate W
```

![MAW private access](https://webeudatastorage.blob.core.windows.net/files/maw-private-access.png)

With clicking on the item details, you can see more information and an option to add comment and download as PDF.

![MAW task detail access](https://webeudatastorage.blob.core.windows.net/files/maw-task-details.png)

## Flow with client app

Client app is already populated with ID in settings. If settings is not entered, then it takes current identity from
Windows. As we are testing functionalities, we will "fake" use access. Flow goes in many cases like this below:

```mermaid
sequenceDiagram
    autonumber
    actor J as John
    participant W as Web Client
    J->>W: Hi Web Client, I am requesting data from you
    Note over J,W: app is recognized, retrieving data for the inquiry.
    activate W
    W->>J: Hi John, here are your data. Anything else you want me to do?
    deactivate W
    J->>W: Hi Web Client, give me for example PDF of my tasks.
    activate W
    W->>J: Sure, here is your byte array.
    deactivate W
```

![WPF app](https://webeudatastorage.blob.core.windows.net/files/maw-wpf-app.png)

## Run the applications

You need to have [pre-requisites](#minimal-requirements) for it to run properly.

### Web App

To run the web application, simply [navigate to web project](../src/TTASLN/TTA.Web) and run the project. To try out
working environment, you'll need:

1. **SQL connection string** - you will need to provide environment variable **SqlOptions__ConnectionString** or add
   connection
   string details in [appsettings.json](../src/TTASLN/TTA.Web/appsettings.json).
2. **Client API URL** - you will need to provide url in environment variable **AppOptions__ClientApiUrl** or add
   connection string details in [appsettings.json](../src/TTASLN/TTA.Web/appsettings.json).

and then run the app with

```
dotnet run
```

### Web API

To run the web api, navigate to that folder and
configure [appsettings.json](../src/TTASLN/TTA.Web.ClientApi/appsettings.json):

1. **SQL connection string** - you will need to provide environment variable **SqlOptions__ConnectionString** or add
   connection
   string details in [appsettings.json](../src/TTASLN/TTA.Web/appsettings.json).

and the run the app with

```
dotnet run
```

### WPF app

To run the WPF app, navigate to that folder and configure [App.config](../src/TTASLN/TTA.Client.Win/App.config):

1. **ClientWebApiUrl** - URL to client API
2. **LoggedUserId** - user id to mimic username

and then run the app with

```
dotnet run
```

You can test the functionality locally. Now to the first task from our CTO.

# Helper links

To help with installation, few links to check out:
1. [PowerShell](https://docs.microsoft.com/en-us/powershell/)
2. [DotNet](https://dot.net)
3. [AZ CLI](https://docs.microsoft.com/en-us/cli/azure/)
4. [Visual Studio](https://visualstudio.com)
5. [Visual Studio Code](https://code.visualstudio.com)
6. [PowerShell for Visual Studio](https://code.visualstudio.com/docs/languages/powershell)
7. [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/install)

# Let's start - Move and automatic configuration in IaaS Azure

The company decided to move to the cloud to take advantage of cloud features - scale, geo support and many more. They
decided to go first with lift and shift approach - in short as is now without any change to code and structure.

[1. Step: Move to Azure](./01-move-to-IaaS-Azure.md)

