# Multiple Availability Zones with Amazon ECS and Terraform

## Table of Contents

- [Description](#Description)
- [Features](#features)
- [Links](#links)
- [How to create the AWS environment with terraform](#how-to-create-the-aws-environment-with-terraform)
- [How to run the demo app](#how-to-run-the-demo-app)

##  Description

This Github project is a demonstration of how to deploy a Dockerized application using Amazon Elastic Container Service (ECS) on AWS. The infrastructure is defined using Terraform, and includes private and public subnets spread across multiple availability zones. The project is a good starting point for those who want to learn how to use ECS and Terraform together, and want to deploy their application in a highly available and scalable manner on AWS.

## Features

- Uses Terraform to manage infrastructure as code
- Deploys an AWS ECS cluster with private and public subnets in multiple availability zones
- Configures the ECS cluster with a load balancer and auto scaling group
- Provides an example Dockerfile and task definition file

## Links

- [Terraform](https://aws.amazon.com/terraform/)
- [AWS ECS](https://aws.amazon.com/ecs/)
- [ECS with Multiple Availability Zones](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-service-discovery.html)


## How to create the AWS environment with terraform

Terraform uses the AWS CLI under the hood. Install the AWS CLI on your machine and configure it work with your AWS account by running the aws configure command and providing your AWS access key, secret access key, and default region.

THe ECS task definition needs to be registered before you apply the terraform script.
```shell
aws ecs register-task-definition --profile <aws-profil> --region eu-central-1 --cli-input-json file://./tf-demo-app/tf-demo-task.json
```

The task definition includes the Docker image to use, the CPU and memory requirements, the networking configuration, and other details needed to launch the container. 

Once a task definition is registered, you can create the AWS environment with terraform.
```shell
terraform init
terraform plan
```

If everything looks good, run terraform apply to create the resources in the specified AWS account and region.
```shell
terraform apply
```

Terraform creates following components:
* VPC with two private and two public subnets
* ECR container repository
* ECS cluster
* ECS task definition, tasks and a service for the demo app
* ALB in the public subnet

The environment can be destroyed with:
```shell
terraform destroy
```

## How to run the demo app

Build the docker image
```shell
cd tf-demo-app
docker build -t tf-demo-app .
```

Start and test the container locally
```shell
docker run --detach --name tf-demo-app -p 80:80 -i -t tf-demo-app
curl localhost
```

Tag and push to ECR Repository
```shell
docker tag tf-demo-app 663216156844.dkr.ecr.eu-central-1.amazonaws.com/tf-demo-app:latest
aws ecr get-login-password --region eu-central-1 --profile patrick-private | docker login --username AWS --password-stdin 663216156844.dkr.ecr.eu-central-1.amazonaws.com
docker push 663216156844.dkr.ecr.eu-central-1.amazonaws.com/tf-demo-app:latest
```

Tag and push the image to Docker Hub Repository
```shell
docker tag tf-demo-app patrickamsler/tf-demo-app:latest
docker login
docker push patrickamsler/tf-demo-app:latest
```

Deploy new version to ECS
1. update the image in the task definition
2. create new revision of the task definition
3. update ecs service to use the new task definition
```shell
aws ecs register-task-definition --profile patrick-private --region eu-central-1 --cli-input-json file://./tf-demo-app/tf-demo-task.json
aws ecs update-service --profile patrick-private --region eu-central-1 --cluster tf-demo-cluster --service tf-demo-ecs-service --task-definition tf-demo-task:<revision>
```

Access demo app in Web Browser http://tf-demo-alb-1374846504.eu-central-1.elb.amazonaws.com/
