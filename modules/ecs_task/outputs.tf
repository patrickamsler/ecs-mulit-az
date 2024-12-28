output "task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = aws_ecs_task_definition.this.arn
}

output "execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  value       = aws_iam_role.execution_role.arn
}

output "task_role_arn" {
  description = "The ARN of the ECS task role (if created)"
  value       = var.create_task_role ? aws_iam_role.task_role[0].arn : null
}