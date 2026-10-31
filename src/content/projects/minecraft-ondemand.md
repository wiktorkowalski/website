---
title: Minecraft on demand
summary: A Minecraft server on AWS that starts when someone wants to play and shuts down when nobody does.
repo: https://github.com/wiktorkowalski/minecraft-ondemand-terraform
stack: [Terraform, AWS, ECS]
status: archived
order: 5
---

World data on EFS, the server on Fargate, and DNS that wakes the whole thing up. Costs close to nothing while nobody plays.
