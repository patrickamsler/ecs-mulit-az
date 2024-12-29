provider "aws" {
  profile = var.profile
  region  = var.region
  default_tags {
    tags = {
      Environment = var.environment
      Owner       = var.owner
    }
  }
}

# Create an ECR repository
module "ecr" {
  source             = "./modules/ecr"
  ecr_name           = var.name
  image_scan_on_push = false
}
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.ecr_repository_url
}

# Create a VPC and subnets
module "network" {
  source = "./modules/network"
  name   = "${var.name}-network"
  vpc_cidr = "10.0.0.0/16" // IP addresses in the range of 10.0.0.0 to 10.0.255.255 (65,536 addresses)
  region = var.region
  public_subnets = {
    # public subnet 2x 251 addresses
    public-a = { cidr = "10.0.0.0/24", az = "a" }
    public-b = { cidr = "10.0.1.0/24", az = "b" }
  }
  private_subnets = {
    # private subnet 2x 4091 addresses
    private-a = { cidr = "10.0.16.0/20", az = "a" }
    private-b = { cidr = "10.0.32.0/20", az = "b" }
  }
}

# Create an ECS cluster
module "ecs_cluster" {
  source       = "./modules/ecs_cluster"
  cluster_name = "${var.name}-ecs-cluster"
}

# Create an ECS task
module "ecs_task" {
  source      = "./modules/ecs_task"
  task_family = "${var.name}-task"
  cpu         = "256"
  memory      = "512"
  requires_compatibilities = ["FARGATE"]
  log_group_name = "/ecs/${var.name}"
  container_definitions = [
    {
      name      = var.name
      image     = "${module.ecr.ecr_repository_url}:latest"
      memory    = 512
      cpu       = 256
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-region"        = var.region
          "awslogs-group"         = "/ecs/${var.name}"
          "awslogs-stream-prefix" = var.name
        }
      }
    }
  ]
  create_task_role = false # Set to true if your application requires AWS API access
}

// Create an ALB
module "alb" {
  source            = "./modules/alb"
  alb_name          = "${var.name}-alb"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  target_group_name = "${var.name}-target-group"
  target_group_port = 80
  target_type       = "ip"
  health_check_path = "/health"
  listener_port     = 80
}
output "alb_url" {
  description = "The URL of the ALB"
  value       = module.alb.alb_url
}

// Create an ECS service
module "ecs_service" {
  source              = "./modules/ecs_service"
  ecs_service_name    = "${var.name}-ecs-service"
  cluster_id          = module.ecs_cluster.ecs_cluster_id
  task_definition_arn = module.ecs_task.task_definition_arn
  desired_count       = 2
  alb_sg_id           = module.alb.alb_security_group_id
  target_group_arn    = module.alb.target_group_arn
  container_name      = var.name
  container_port      = 80
  subnets             = module.network.private_subnet_ids
  vpc_id              = module.network.vpc_id
}