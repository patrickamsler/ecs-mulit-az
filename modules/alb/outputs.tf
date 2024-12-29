output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_alb.application_load_balancer.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_alb.application_load_balancer.dns_name
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.target_group.arn
}

output "listener_arn" {
  description = "The ARN of the ALB listener"
  value       = aws_lb_listener.listener.arn
}

output "security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.load_balancer_security_group.id
}