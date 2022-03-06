# ecs-mulit-az

## How to set up the AWS environment

Setup the environment
```shell
terraform init
terraform apply
```

Terraform will start up:
* VPC with two private and two public subnets
* ECR container repository
* ECS cluster
* ECS task definition, tasks and a service for the demo app
* ALB in the public subnet

Destroy the environment
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