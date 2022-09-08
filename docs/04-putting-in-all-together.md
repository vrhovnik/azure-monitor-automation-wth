# Putting it all together

<!-- TOC -->
* [Putting it all together](#putting-it-all-together)
  * [Requirements](#requirements)
  * [Key Takeaways](#key-takeaways)
* [Something happened](#something-happened)
<!-- TOC -->

CTO have seen different teams leveraging your code. Copying and doing manual work already resulted in errors and
challenges.
As a team we decided to create pipelines to use all the work we had to populate solution on source change. CTO decided
to leverage [GitHub](https://github.com) as primary solution and to create option to execute different options manually.

## Requirements

To satisfy the request you need to:

1. fork [https://github.com/vrhovnik/azure-monitor-automation-wth](https://github.com/vrhovnik/azure-monitor-automation-wth)
2. create pipelines to create resources for IaaS, Scale and Modernize
3. populate database with different options - bak file [here](../scripts/PWSH/03-Modernization/TTADB.bak), sql script [here](../scripts/PWSH/03-Modernization/ttadb.sql)
4. provide manual way as primary trigger to execute workflows

## Key Takeaways

You'll learn how to:
1. configure DevOps pipeline based on triggers
2. modify scripts to take advantage of built-in features in GitHub to understand how to adjust the on-prem vs cloud options
3. prepare your own environment to easily deploy solution to new customers

# Something happened

Some members of the team started to complain, that their app is not working as it should. Some random errors have
occured and it is hurting the productivity. CTO decided for you to be the hero to save the day. Press button to
continue.

[ Putting it all together >>](./04-putting-in-all-together.md) | [ Something happened >>](./05-monitoring-basics.md)
