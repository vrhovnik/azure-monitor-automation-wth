# Monitoring previews

<!-- TOC -->
* [Monitoring previews](#monitoring-previews)
  * [Task requirement](#task-requirement)
  * [Test the functionality](#test-the-functionality)
* [Expected learnings](#expected-learnings)
* [Useful links](#useful-links)
<!-- TOC -->

Solution is now up and running, basic monitoring is prepared and ready to use. CEO approached the team and asked to
prepare a demo for the next board meeting. CEO wants to show how the
solution is performing and demonstrate by customer how they are using the app.

## Task requirement

Your job is to prepare the overview for the CEO:

1. create rich graphics and dashboards to preview the solution overall health and performance:
    - create a dashboard with the following metrics:
        - CPU and memory usage
        - Network usage and number of requests
        - server response time
        - availability over time
    - create a dashboard with the following metrics:
        - number of users - active and per country
        - number of errors and most common error
2. provide an ability to connect to external systems like PowerBI or Grafana to preview the data

## Test the functionality

Showcase the dashboard to the CEO and the customer. Examples of monitoring below.

# Expected learnings

1. Understand how to leverage Azure Monitor workbooks to prepare the app overview
2. Understand how to connect Azure Monitor to other solutions to create rich graphical overview3.
3. Understand how to use Azure Monitor to monitor the application and infrastructure together
4. Demonstrate from Azure Monitor to notify and react to the errors
5. Showcase how you can use the result in an external system like PowerBI or Grafana - pick which you would like to
   explore and demonstrate the chart in that tool

# Useful links

1. [Log Queries in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-query-overview)
2. [Kusto Query](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/)
2. [Azure Workbooks](https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/workbooks-overview)
2. [Grafana](https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/grafana-plugin)
3. [PowerBI](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-powerbi)

[<< Enable Monitoring](./05-monitoring-basics.md) | [<< Back to the challenges](./00-challenges.md)