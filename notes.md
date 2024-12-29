# Terraform Module Overview

| **Module Name**  | **Description**                                                                                             | **Examples of Resources**                                                                                     |
|-------------------|-----------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| **network**       | Handles the VPC, subnets, NAT gateways, and related networking resources.                                 | `aws_vpc`, `aws_subnet`, `aws_internet_gateway`, `aws_nat_gateway`, `aws_route_table`                         |
| **alb**           | Manages the Application Load Balancer and its related resources.                                           | `aws_lb`, `aws_lb_target_group`, `aws_lb_listener`                                                            |
| **ecr**           | Manages the Elastic Container Registry (ECR) and related permissions.                                      | `aws_ecr_repository`, `aws_iam_role` for ECR access                                                          |
| **ecs_cluster**   | Manages the ECS cluster.                                                                                   | `aws_ecs_cluster`, `aws_iam_role` for ECS                                                                     |
| **ecs_task**      | Manages the ECS task definition and associated roles for tasks.                                            | `aws_ecs_task_definition`, `aws_iam_role`, `aws_iam_policy`                                                   |
| **ecs_service**   | Manages the ECS service and its integration with ALB, tasks, and autoscaling.                              | `aws_ecs_service`, `aws_appautoscaling_target`, `aws_appautoscaling_policy`                                   |
| **security**      | Handles security groups and other networking rules for all modules.                                        | `aws_security_group`, `aws_security_group_rule`                                                               |
| **dns** (optional)| Manages DNS records for routing traffic to ALB or other endpoints.                                         | `aws_route53_record`, `aws_route53_zone`                                                                      |
| **monitoring**    | Manages CloudWatch alarms, logs, and metrics for ECS services and ALB.                                     | `aws_cloudwatch_log_group`, `aws_cloudwatch_alarm`, `aws_cloudwatch_dashboard`                                 |


# Terraform ECS Demo
init terraform:
```bash
terraform init
```

First setup ecr repository:
```bash
terraform plan -target=module.ecr
terraform apply -target=module.ecr
```
int should output the ecr repository url: ecr_repository_url = "<account_id>.dkr.ecr.<region>.amazonaws.com/ecs-terraform-demo"


Get the account id:
```bash
aws sts get-caller-identity --query Account --output text
```
Build the docker image for x86_64:
```bash
cd docker
docker build --platform linux/amd64 -t ecs-terraform-demo .
```
Test the docker image locally:
```bash
docker build -t ecs-terraform-demo .
docker run --detach --name ecs-terraform-demo -p 80:80 -i -t ecs-terraform-demo
curl localhost
```
Get the account id:
```bash
aws sts get-caller-identity --query Account --output text
```
Tag the docker image and push it to ECR:
```bash
docker tag ecs-terraform-demo <repo-url>:latest
aws ecr get-login-password --region <region> --profile <profile> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com
docker push <repo-url>:latest
```