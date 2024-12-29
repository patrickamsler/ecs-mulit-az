# ECS Task Execution Role
resource "aws_iam_role" "execution_role" {
  name = "${var.task_family}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach policies to the execution role
resource "aws_iam_role_policy_attachment" "execution_policy_attachment" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (optional for applications requiring AWS API access such as S3 or DynamoDB)
resource "aws_iam_role" "task_role" {
  count = var.create_task_role ? 1 : 0

  name = "${var.task_family}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_in_days # Optional: set log retention
}

# ECS Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = var.task_family
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = var.create_task_role ? aws_iam_role.task_role[0].arn : null
  requires_compatibilities = var.requires_compatibilities
  network_mode             = var.network_mode
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = jsonencode(var.container_definitions)
}