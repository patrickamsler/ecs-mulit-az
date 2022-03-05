provider "aws" {
  profile = "patrick-private"
  region  = var.region
  default_tags {
    tags = {
      Environment = "Test"
      Owner = "Patrick"
    }
  }
}

module "tf_demo_vpc" {
  source = "./modules/vpc"
  name = "tf-demo-aws-vpc"
  vpc_cidr = "10.0.0.0/16" // 10.0.0.0 - 10.0.255.255
}

module "public_subnet_a" {
  source = "./modules/public_subnet"
  name = "tf-demo-public-subnet-a"
  vpc_id = module.tf_demo_vpc.vpc_id
  subnet_cidr_block = "10.0.0.0/24" // 251 public addresses
  az = "${var.region}a"
  igw_id = module.tf_demo_vpc.igw_id // vpc internet gateway
}

module "public_subnet_b" {
  source = "./modules/public_subnet"
  name = "tf-demo-public-subnet-b"
  vpc_id = module.tf_demo_vpc.vpc_id
  subnet_cidr_block = "10.0.1.0/24" // 251 public addresses
  az = "${var.region}b"
  igw_id = module.tf_demo_vpc.igw_id // vpc internet gateway
}

module "private_subnet_a" {
  source = "./modules/private_subnet"
  name = "tf-demo-private-subnet-a"
  vpc_id = module.tf_demo_vpc.vpc_id
  subnet_cidr_block = "10.0.16.0/20" // 4091 private addresses
  az = "${var.region}a"
  nat_gw_id = module.public_subnet_a.nat_gw_id // nat gateway in public subnet a
}

module "private_subnet_b" {
  source = "./modules/private_subnet"
  name = "tf-demo-private-subnet-b"
  vpc_id = module.tf_demo_vpc.vpc_id
  subnet_cidr_block = "10.0.32.0/20" // 4091 private addresses
  az = "${var.region}b"
  nat_gw_id = module.public_subnet_b.nat_gw_id // nat gateway in public subnet b
}

// registry
resource "aws_ecr_repository" "aws-ecr" {
  name = "tf-demo-app"
}

// IAM policy to enable the service to pull the image from ECR.
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "tf-demo-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

// create the cluster
resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "tf-demo-cluster"
}

// create Log Group on CloudWatch to get the containers logs
resource "aws_cloudwatch_log_group" "log-group" {
  name = "tf-demo-logs"
}

// Task Definition compatible with AWS FARGATE
#data "template_file" "env_vars" {
#  template = file("env_vars.json")
#}
#
#resource "aws_ecs_task_definition" "aws-ecs-task" {
#  family = "tf-demo-task"
#
#  container_definitions = <<DEFINITION
#  [
#    {
#      "name": "tf-demo-app",
#      "image": "${aws_ecr_repository.aws-ecr.repository_url}:latest",
#      "entryPoint": [],
#      "environment": ${data.template_file.env_vars.rendered},
#      "essential": true,
#      "logConfiguration": {
#        "logDriver": "awslogs",
#        "options": {
#          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
#          "awslogs-region": "${var.region}",
#          "awslogs-stream-prefix": "tf-demo-app"
#        }
#      },
#      "portMappings": [
#        {
#          "containerPort": 8080,
#          "hostPort": 8080
#        }
#      ],
#      "cpu": 256,
#      "memory": 512,
#      "networkMode": "awsvpc"
#    }
#  ]
#  DEFINITION
#
#  requires_compatibilities = ["FARGATE"]
#  network_mode             = "awsvpc"
#  memory                   = "512"
#  cpu                      = "256"
#  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
#  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
#}
#
#data "aws_ecs_task_definition" "main" {
#  task_definition = aws_ecs_task_definition.aws-ecs-task.family
#}