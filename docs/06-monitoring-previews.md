# Monitoring previews

<!-- TOC -->
* [Monitoring previews](#monitoring-previews)
  * [Task requirements](#task-requirements)
  * [Test the functionality](#test-the-functionality)
* [Expected learnings](#expected-learnings)
* [Useful links](#useful-links)
<!-- TOC -->

Solution is now up and running, basic monitoring is prepared and ready to use. CEO approached the team and asked to
prepare status report. Team wants to have interactive dashboards to be able to show the status of the system and to
drill down into specifics and details if needed.

You can use native solutions to create monitoring options or use third party tools like Managed Grafana
to provide this information to the end user.

## Task requirements

Your job is to prepare the overview for your team:

1. create rich graphics and dashboards to preview the solution overall health and performance:
    - create simple dashboard for your team by providing (if you are using native solution, you can use [this template](https://webeudatastorage.blob.core.windows.net/web/appInsightStarterTemplate.json) as a
      starter)
        - App insights and Azure Monitor alerts overview -how many dashboard, how many workbooks, if there are any url tests, defined smart detection rules
        - overall overview of application statistics (custom metrics, traces, performanceCounters, requests, dependencies, availability results, exceptions, pageViews, browserTimings)
        - interactive tab to show results in your subscriptions 
          - all defined workbooks 
          - alerting resources by providing table with resource group name, alert status, alert state, alert time, severity, deep details link
          - workbook overview by type, location, resource group, enabled, type and deep details link
        - Exception list with query from previous task
    - create master Azure dashboard dashboard and fill it in with following metrics:
        - Average CPU usage and available memory
        - Average availability and server response time
        - Unique sessions and users
        - Failed requests
        - Average page load time breakdown
    - pin to Azure dashboard deep links to interactive reports (clicking on blade gives you in depth information):
        - [Apdex Performance analysis](https://www.apdex.org/) of the application
        - link to sample end-to-end transaction with an ability to modify query on Azure Dashboard
        - Exception overview with trend graph
2. provide an ability to download data and connect to external systems like Excell or PowerBI

## Test the functionality

Showcase the dashboard to the coach and the team by providing rich examples of data from task requirements and explaing
what it does.

Examples of how monitoring should be done:

![Common dashboard](https://webeudatastorage.blob.core.windows.net/web/app-insight-example.png)

or

![exception list information](https://webeudatastorage.blob.core.windows.net/web/app-insight-exception-list.png)

or

![Interactive tabs](https://webeudatastorage.blob.core.windows.net/web/app-insight-interactive-tab.png)

or

![Managed Grafana Overview](https://webeudatastorage.blob.core.windows.net/web/app-insight-grafana.png)

# Expected learnings

1. Understand how to leverage Azure Monitor / Application Insights workbooks to prepare the app overview
2. Understand how to connect Azure Monitor to other solutions to create rich graphical overview
3. Understand how to use Azure Monitor and queries to monitor the application and infrastructure together
4. Showcase how you can use the result in an external system like Excell or Teams or PowerBI or Grafana

# Useful links

1. [Log Queries in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-query-overview)
2. [Kusto Query](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/)
3. [Azure Workbooks](https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/workbooks-overview) - tutorial how
   to [create Azure Workbook](https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/workbooks-create-workbook)
   - starter template [here](https://webeudatastorage.blob.core.windows.net/web/appInsightStarterTemplate.json)
4. [Azure Managed Grafana](https://learn.microsoft.com/en-us/azure/managed-grafana/overview)
5. [PowerBI](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-powerbi)

[<< Enable Monitoring](./05-monitoring-basics.md) | [<< Back to the challenges](./00-challenges.md)