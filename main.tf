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

// registry
resource "aws_ecr_repository" "aws-ecr-tf-demo-app" {
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
resource "aws_ecs_cluster" "tf-demo-ecs-cluster" {
  name = "tf-demo-cluster"
}

// create Log Group on CloudWatch to get the containers logs
resource "aws_cloudwatch_log_group" "tf-demo-log-group" {
  name = "tf-demo-logs"
}

// Task Definition compatible with AWS FARGATE
resource "aws_ecs_task_definition" "tf-demo-ecs-task-definition" {
  family = "tf-demo-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "tf-demo-app-container",
      "image": "${aws_ecr_repository.aws-ecr-tf-demo-app.repository_url}:latest",
      "entryPoint": [],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.tf-demo-log-group.id}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "tf-demo-app"
        }
      },
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],
      "cpu": 256,
      "memory": 512,
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.tf-demo-ecs-task-definition.family
}

resource "aws_ecs_service" "tf-demo-ecs-service" {
  name                 = "tf-demo-ecs-service"
  cluster              = aws_ecs_cluster.tf-demo-ecs-cluster.id
  task_definition      = "${aws_ecs_task_definition.tf-demo-ecs-task-definition.family}:${max(aws_ecs_task_definition.tf-demo-ecs-task-definition.revision, data.aws_ecs_task_definition.main.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 2
  force_new_deployment = true

  network_configuration {
    subnets          = [module.private_subnet_a.id, module.private_subnet_b.id]
    assign_public_ip = false
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "tf-demo-app-container"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.listener]
}

resource "aws_security_group" "service_security_group" {
  vpc_id = module.tf_demo_vpc.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer_security_group.id] //only allow ingress from load balancer
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_alb" "application_load_balancer" {
  name               = "tf-demo-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [module.public_subnet_a.id, module.public_subnet_b.id]
  security_groups    = [aws_security_group.load_balancer_security_group.id]
}

resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = module.tf_demo_vpc.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "tf-demo-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.tf_demo_vpc.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/" //route on the application that the Load Balancer will use to check the status
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.id
  }
}