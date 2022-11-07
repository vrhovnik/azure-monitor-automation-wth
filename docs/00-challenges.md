# Challenges

<!-- TOC -->
* [Challenges](#challenges)
  * [Workload technical overview and how to deploy it on local machine](#workload-technical-overview-and-how-to-deploy-it-on-local-machine)
  * [Challenge 1: Works on my remote machine](#challenge-1--works-on-my-remote-machine)
  * [Challenge 2: VM was not responding, can you give me another instance?](#challenge-2--vm-was-not-responding-can-you-give-me-another-instance)
  * [Challenge 3: Workload modernization and native integration](#challenge-3--workload-modernization-and-native-integration)
  * [Challenge 4: One Monitor solution to rule them all](#challenge-4--one-monitor-solution-to-rule-them-all)
  * [Challenge 5: Show me the results](#challenge-5--show-me-the-results)
<!-- TOC -->

We recommend by solving challenges one by one. If you don't have all the tools install, you can always use
[Azure Shell](https://shell.azure.com) with everything pre-installed. First three challenges can be tackled
independently, monitoring challenges need to be solved in order, starting with basics.

## Workload technical overview and how to deploy it on local machine

To understand the workload and how to deploy it locally, please follow the instructions in this [document](./00-init.md).

## Challenge 1: Works on my remote machine

Task is to setup the application and infrastructure in Azure for specific customers. You have the application code and
you need to define a process to deploy it to Azure for all and for one customer. You can leverage tools like Terraform,
ARM templates, Azure CLI, Azure
PowerShell and many more to solve the task at hand.

[Start with challenge 1](./01-move-to-IaaS-Azure.md)

## Challenge 2: VM was not responding, can you give me another instance?

Task is to setup the application and infrastructure in Azure for specific customers to suport resiliency with virtual
machines.
You have the application code and you need to define a process to deploy it to Azure for all and for one customer. You
can leverage tools like Terraform, ARM templates, Azure CLI, Azure
PowerShell and many more to solve the task at hand. You need to configure load balancer and multiple machines with SQL
database behind the scenes to handle the resiliency.

[Start with challenge 2](./01-move-to-IaaS-Azure.md)

## Challenge 3: Workload modernization and native integration

You were provided with docker files with instructions how the solutions works. Data team provided you with SQL backup
file.
You need to deploy the application to Azure and make sure it works.

[Start with challenge 3](./03-modernization-in-Azure.md)

## Challenge 4: One Monitor solution to rule them all

App is up and running. Some customers saw challenges with random errors or application began slowly responding. Your
task is to enable monitoring to understand what is happening with the application and notify users about the errors. If you
spike has been noticed, you need to configure system to adhere to that new load automatically. DevOps team provided you with fix and you now need to
deploy the solution and repeat the monitoring process.

[Start with challenge 4](./05-monitoring-basics.md)

## Challenge 5: Show me the results

Your app is constantly evolving and adding new features. You need to understand how to use them and how to showcase the
solution to the users. In this task you are preparing the solution to be showcased to the users who are not technically savvy and are
interested in how the app is performing.

