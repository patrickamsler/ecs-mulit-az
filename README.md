# ecs-mulit-az

## How to set up the AWS environment

Register task definition
```shell
aws ecs register-task-definition --profile patrick-private --region eu-central-1 --cli-input-json file://./tf-demo-app/tf-demo-task.json
```

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

Deploy new version to ECS
1. update the image in the task definition
2. create new revision of the task definition
3. update ecs service to use the new task definition
```shell
aws ecs register-task-definition --profile patrick-private --region eu-central-1 --cli-input-json file://./tf-demo-app/tf-demo-task.json
aws ecs update-service --profile patrick-private --region eu-central-1 --cluster tf-demo-cluster --service tf-demo-ecs-service --task-definition tf-demo-task:<revision>
```

Access demo app in Web Browser http://tf-demo-alb-1374846504.eu-central-1.elb.amazonaws.com/
