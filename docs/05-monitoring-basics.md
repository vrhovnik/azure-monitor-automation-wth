# Monitoring basics

<!-- TOC -->

* [Monitoring basics](#monitoring-basics)
    * [Task requirement](#task-requirement)
    * [Test the functionality](#test-the-functionality)
* [Expected learnings](#expected-learnings)

<!-- TOC -->

Solution is now up and running. Some customers saw challenges with random errors or application not to anything.
Go and enable monitoring to understand what is happening with the application and to mitigate the errors. Customers
provided few screenshots and information about the errors.

You should have at least 1 VM with solution and 1 container app to see the different. 

If you don't have it deployed or you deleted everything from before, you can use the following scripts to set them up from scratch:
1. deploy VM with solution: 
2. deploy container app: 

## Task requirement

1. Enable monitoring automatically on all of the customer solutions you have in Azure - infrastructure and application
2. Provide a script (jMeter, PowerShell, Bash, ...) to generate some load on the application
3. [OPTIONAL] add script to DevOps process to generate load on the application via CI/CD pipeline after deployment has succeeded
4. monitor load and after receiving more than 10% load, scale the affected application by 1 instance automatically
5. find the errors in the application and create an alert to notify users about the errors by using emails 

## Test the functionality

1. Generate load on the application and monitor via Azure Monitor how the application is performing
2. Scale the application automatically when load is more than 10% - going up
3. When error occurs, demonstrate how the alert is triggered and how the notification is sent

# Expected learnings

1. Understand how to enable monitoring in Azure for different type of solutions
2. Understand how to use Azure Monitor to monitor the application
3. Understand how to use Azure Monitor to monitor the infrastructure 
4. Use mechanisms from Azure Monitor to notify and react to the errors 
5. Leverage built-in mechanisms to scale the application automatically 

# Useful links

1. [Azure Monitor overview](https://learn.microsoft.com/en-us/azure/azure-monitor/monitor-reference)
2. [Azure Load Testing](https://learn.microsoft.com/en-us/azure/load-testing/overview-what-is-azure-load-testing)
3. [jMeter](https://jmeter.apache.org/) 
3. [Bombardier benchmarking tool](https://github.com/codesenberg/bombardier) 

[<< Enable Monitoring](./03-modernization-in-Azure.md) | [<< Back to the challenges](../README.md)
| [Monitoring previews >>](./06-monitoring-previews.md)  