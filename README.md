# PokeFightII_Terraformed
Terraform module for deploying PokeFightII in AWS!

Uses Terraform to deploy an AWS EC2 instance with Ubuntu 22.04 and runs a script from user data:
- Installs git and clones two other repos of mine ("MrATXDockerScripts" and "PokeFightII_Dockerized")
- Runs install Docker script then runs docker compuse up within the PokeFightII_Dockerized repo
- Terraform outputs the app url "instancePublicIp:5000" and with a minute or two, the app will be running on that url

Deploys a Security Group with an ingress rule allowing access to port 5000 from the IP you run the Terraform plan from, and with open egress.

The "defaultVpc" version of the module only deploys the EC2 instance and Security Group.

The "fullNetStack" version of the module creates an independent networking setup for the app by also deploying a VPC, public subnet, Internet Gateway (IGW), and route table.


*** Requirements
- An AWS Account
- AWS CLI
- Terraform
- That should be it!


Notes
- Deafult region is us-west-2
- SG doesn't allow SSH access
- It does take a minute or two for the app to spin up
