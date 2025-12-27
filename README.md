# PokeFightII_Terraformed
Terraform module for deploying PokeFightII in AWS!

Uses Terraform to deploy an AWS EC2 instance to host an instance of Poke Fight II for you to play securely from your computer!
- EC2 instance using Ubuntu 22.04
- Bash script runs via user data
- Security Group with an ingress rule allowing access to port 5000 from the IP you run the Terraform plan from, and with open egress

The Bash script:
- Installs git and clones two other repos of mine ("MrATXDockerScripts" and "PokeFightII_Dockerized")
- Runs install Docker script from "MrATXDockerScripts", then runs docker compose up within the "PokeFightII_Dockerized" repo to start the app
- On successful apply, Terraform outputs the app url "instancePublicIp:5000" and within a minute or two, the app will be running on that url for you to play

The "defaultVpc" version of the module only deploys the EC2 instance and Security Group, which will use the default VPC and one of its subnets for the region.

The "fullNetStack" version of the module creates an independent networking setup for the app by also deploying a VPC, public subnet, Internet Gateway (IGW), and route table.


*** Requirements
- An AWS Account
- AWS CLI
- Terraform
- That should be it!


Notes
- Deafult region is us-west-2
- Security Group doesn't allow SSH access
- It does take a minute or two for the app to spin up
