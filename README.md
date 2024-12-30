# AWS Multi AZ ECS with Terraform

<!-- TOC -->
* [AWS Multi AZ ECS with Terraform](#aws-multi-az-ecs-with-terraform)
  * [Description](#description)
  * [Project Structure](#project-structure)
  * [Architecture Diagram](#architecture-diagram)
  * [How to create the ECS cluster with Terraform](#how-to-create-the-ecs-cluster-with-terraform)
    * [Deploy new version to ECS](#deploy-new-version-to-ecs)
<!-- TOC -->

##  Description

This Github project is a demonstration of how to deploy a Dockerized application using Amazon Elastic Container Service (ECS) on AWS. The infrastructure is defined using Terraform, and includes private and public subnets spread across multiple availability zones. The project is a good starting point for those who want to learn how to use ECS and Terraform together, and want to deploy their application in a highly available and scalable manner on AWS.


## Project Structure

The project consists of multiple terraform modules:

| Module      | Description                                                                                                                      |
|-------------|----------------------------------------------------------------------------------------------------------------------------------|
| alb         | Manages the AWS Application Load Balancer configuration, including target groups and listeners for routing traffic to ECS tasks. |
| ecr         | Creates and configures an Elastic Container Registry (ECR) to store, version, and secure Docker container images.                |
| ecs_cluster | Provisions and manages the AWS ECS cluster, which serves as the logical grouping of AWS Fargate tasks.                           |
| ecs_service | Defines and deploys an ECS Service, ensuring your ECS tasks remain healthy and the desired count is maintained.                  |
| ecs_task    | Configures the ECS Task Definition, including container images, CPU/memory allocation, environment variables, and port mappings. |
| network     | Sets up the VPC network, public and private subnets, NAT gateways, and related route tables.                                     |

## Architecture Diagram

```
  Internet
     |
   (ALB)
     |
 [ECS Service] ---> [ECS Tasks] ---> [ECR]
     |
 [ECS Cluster]
     |
 (VPC/Network)
```

## ECS Components

- **ECS Cluster**: A logical grouping of ECS tasks that run on AWS Fargate or EC2 instances. The ECS cluster is responsible for managing the underlying infrastructure and scheduling tasks on the available resources.
- **ECS Task Definition**: A blueprint for your application that defines how the Docker containers should be launched and configured. It includes information such as the Docker image, CPU/memory allocation, environment variables, and port mappings.
- **ECS Task**: An instance of a task definition that runs as a Docker container on an ECS cluster. The task is the smallest deployable unit in ECS and represents a single running instance of your application.
- **ECS Service**: Ensures that the desired number of tasks are running and healthy. It maintains the desired count of tasks and automatically restarts failed tasks. The ECS service is associated with an Application Load Balancer (ALB) to route traffic to the ECS tasks.
- **Elastic Container Registry (ECR)**: A fully managed Docker container registry that makes it easy to store, manage, and deploy Docker container images. It integrates with ECS to simplify the deployment of containerized applications.

## How to create the ECS cluster with Terraform

Terraform uses the AWS CLI under the hood. Install the AWS CLI on your machine and configure it to work with your AWS account by running the aws configure command and providing your AWS access key and secret access key.

- [AWS CLI installation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform setup](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

First initialize the terraform modules
```shell
terraform init
```

Before you can create the ECS cluster, you need to create an Elastic Container Registry (ECR) to store your Docker images.
```shell
terraform plan -target=module.ecr
terraform apply -target=module.ecr
```
Terraform outputs the ECR repository url: ecr_repository_url = "<account_id>.dkr.ecr.<region>.amazonaws.com/ecs-terraform-demo"

After that you need to build the Docker image for the demo app and push it to the ECR repository.

(Optional) You can build and test the docker image locally:
```bash
docker build -t ecs-terraform-demo .
docker run --detach --name ecs-terraform-demo -p 80:80 -i -t ecs-terraform-demo
curl localhost
```

Build the docker image for x86_64 before pushing it to the ECR repository:
```bash
cd docker
docker build --platform linux/amd64 -t ecs-terraform-demo .
```

Get your account id:
```bash
aws sts get-caller-identity --query Account --output text
```

Tag the docker image with the <repo-url>:latest, configure the AWS CLI to authenticate Docker to your ECR registry, and push the image to the ECR repository.
```bash
docker tag ecs-terraform-demo <repo-url>:latest
aws ecr get-login-password --region <region> --profile <profile> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com
docker push <repo-url>:latest
```

Once the Docker image is pushed to the ECR repository, you can create the ECS cluster with the following commands:
```shell
terraform plan
```
If everything looks good, run terraform apply to create the resources in the specified AWS account and region.
```shell
terraform apply
```

Terraform creates following components:
* VPC with two private and two public subnets
* ECS cluster
* ECS task definition, tasks and a service for the demo app
* ALB in the public subnet

After the Terraform apply command completes, you can access the demo app by navigating to the ALB DNS name in your web browser.

For cleanup, you can run the following command to destroy all the resources created by Terraform:
```shell
terraform destroy
```

### Deploy new version to ECS
1. update the image in the task definition
2. create new revision of the task definition
3. update ecs service to use the new task definition
```shell
aws ecs register-task-definition --profile <aws-profil> --region eu-central-1 --cli-input-json file://./tf-demo-app/tf-demo-task.json
aws ecs update-service --profile <aws-profil> --region eu-central-1 --cluster tf-demo-cluster --service tf-demo-ecs-service --task-definition tf-demo-task:<revision>
```


