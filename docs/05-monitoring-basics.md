﻿# Monitoring basics

<!-- TOC -->
* [Monitoring basics](#monitoring-basics)
  * [Pre-requisites](#pre-requisites)
  * [Task requirement](#task-requirement)
    * [General](#general)
    * [System monitoring](#system-monitoring)
      * [Containers](#containers)
      * [VMs](#vms)
    * [App monitoring](#app-monitoring)
  * [Test the functionality and success criteria](#test-the-functionality-and-success-criteria)
* [Expected learnings](#expected-learnings)
* [Useful links](#useful-links)
<!-- TOC -->

Solution is now up and running. Some customers saw challenges with random errors or application not to anything.
Go and enable monitoring to understand what is happening with the application and to mitigate the errors. Customers
provided few screenshots and information about the errors.

## Pre-requisites

By finishing first two challenges you _should_ have at least 1 VM with solution (or 1 VMSS with load balancer in
front) **and** 1 container app up and running.

If you skipped the challenges you can deploy them now by using selected option. It will take around 15 min max to have
them up and running. You were provided with one database as a service to rule them all.

Instruction how to do that are available [here](05-monitoring-basics-prereq.md).

## Task requirement

### General

1. Enable monitoring (infrastructure and application) on all of the customer solutions you have in Azure without
   modifying the application code and make sure all new solutions on VMs will be automatically onboarded to Azure
   Monitor.
2. Provide a script (jMeter, PowerShell, Bash, ...) or use another tool to generate some load on the application to test
   out functionality - you can test base url and virtual url Tasks.
3. [OPTIONAL] add script / use tool in DevOps process to generate load on the application via CI/CD pipeline after
   deployment has succeeded with codeowner approval.

### System monitoring

#### Containers

1. Monitor load in containers and if received more than 50 requests per second in a container, scale the affected
   application by 1 instance automatically.
2. Monitor load in containers and if CPU consumed goes over 10%, scale the application by 1 instance.
3. Create an alert if the threshold goes over 100 requests and if CPU goes over 1 core over period of 5 mins, but only
   for successful requests. Notify users by your own choice (email, SMS, ...). If you don't have email option, create
   Azure Function and echo the message.

#### VMs

1. Monitor load in VM and check out the percentage usage of CPU usage in that VM (CPU credits is not what we are looking
   for).
2. Monitor load in VM and if received **more** than 100 mb of RAM allocated to specific process w3wp (in which app
   resides - in
   short **private bytes for the IIS process w3wp.exe**), restart the VM to free the allocated memory and notify owner
   via email. If you don't have email setup, simulate by creating
   Azure Function (with consumption plan) and echoing the result.
3. Create alerts for VM and notify user by your choice via email:
    - if percentage CPU is greater than 80% by defining critical severity
    - if data disk IOPS consumed percentage is greater than 90% with verbose severity
    - if network in total is greater than 800 GB with information severity
4. Enable on VM to use application insights to monitor the application (without changing the application configuration
   settings - discuss with coach what options do they have if they need to change the settings in code) and send logs to
   it to be able to have one place
   for applications to monitor performance, transactions, failures, maps, etc.
5. Replace connection string for web application in VM - simple instructions below:
    - connect to the VM via RDP
    - replace connection string in the **appsettings.json** file (section **SQLOptions**, property **ConnectionString**)
      with connection string from Azure SQL
    - replace connection string in the **appsettings.json** file (section **ApplicationInsights**,
      property **ConnectionString**) with connection string from Application Insights
    - restart the application (**Windows + R**, **inetmgr** (Enter), select **default application pool**, right click,
      select **recycle**) or via
      PowerShell (**[Restart-WebAppPool](https://learn.microsoft.com/en-us/powershell/module/webadministration/restart-webapppool?view=windowsserver2022-ps)**)
      or via CLI commands (net stop was /y and then
      net start w3svc)
    - open http://localhost/ttaweb/tasks in the browser
    - repeat load test, navigate to app insights and check application map, live metrics and explain what changed

### App monitoring

1. Find the errors in the applications by defining **ONE** query with data for the application by providing:
    - timeline option to be able to provide range in query
    - to see exceptions by the name, request duration, method, error message, instance where it happened, called url by
      providing time range
    - showcase the data in Excell
2. Create an accoutn on container app instance (URL/User/Register). Create an account and add few records (tasks). Click
   on username to navigate to dashboard. Repeat a few times. Search for a transaction "UserProfile" and explain to the
   coach what are you seeing (code implemention is available [here](https://github.com/vrhovnik/azure-monitor-automation-wth/blob/main/src/TTASLN/TTA.Web/Pages/User/Dashboard.cshtml.cs#L50)).
3. Notify application users (IAM role owner) when you see that pages are slow to respond. Defition of slow is responding
   more than 2s and we want for product manager to be aware. if you don't have email options, simulate by creating Azure
   Function (consumption plan).

## Test the functionality and success criteria

1. Describe the coach how to enable monitoring on all of the solutions (pros and cons) - infrastructure and application
   for VM (or VMSS) and container app
    - explain what needs to be done in order to make it happen
    - how should you consolidate data from different sources to have the overall view of the system
    - how should you monitor the application itself without changing the code of the application
2. Generate load on the application and monitor via possible solutions in Azure how the application is performing -
   provide to coach the information about how the app is performing, how many users are connecting, trace of the
   request, etc.
3. Demonstrate exception details to the coach by using Microsoft Excell with the respond option.
4. When error occurs and pages become slow, demonstrate how the alert is triggered and how the notification is sent to
   appropriate users.

# Expected learnings

1. Understand how to enable monitoring in Azure for different type of solutions
2. Understand how to use Azure Monitor to monitor the application
3. Understand how to use Azure Monitor to monitor the infrastructure
4. Use mechanisms from Azure Monitor and Application Insights to notify and react to the metrics changes and log
   requirements
5. Leverage built-in mechanisms to scale the application automatically or use custom option to react on changes
6. Understand and modify Kusto Query to get information you need across all of the solutions

# Useful links

1. [Azure Monitor overview](https://learn.microsoft.com/en-us/azure/azure-monitor/monitor-reference)
2. [Azure Load Testing](https://learn.microsoft.com/en-us/azure/load-testing/overview-what-is-azure-load-testing)
   or [jMeter](https://jmeter.apache.org/) or [Bombardier benchmarking tool](https://github.com/codesenberg/bombardier)
3. [Azure Monitor policies](https://learn.microsoft.com/en-us/azure/azure-monitor/policy-reference)
   and [Policy effects](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/effects)
4. [Application Insights overview](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
5. [Application insights on VM](https://learn.microsoft.com/en-us/azure/azure-monitor/app/azure-vm-vmss-apps?tabs=core)
6. [Azure Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/quickstart-create-first-logic-app-workflow)
7. [Azure Container App Observability](https://learn.microsoft.com/en-us/azure/container-apps/observability)
8. [Kusto Query](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/)
   and [Azure Monitor Log Analytics API](https://dev.loganalytics.io/)
9. [Azure REST API](https://learn.microsoft.com/en-us/rest/api/azure/)

[<< Enable Monitoring](./03-modernization-in-Azure.md) | [<< Back to the challenges](./00-challenges.md)
| [Monitoring previews >>](./06-monitoring-previews.md)  