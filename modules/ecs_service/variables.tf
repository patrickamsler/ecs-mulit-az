variable "ecs_service_name" {
  type        = string
  description = "Name for the ECS service."
}

variable "cluster_id" {
  type        = string
  description = "The ID (or ARN) of the ECS cluster on which to run the service."
}

variable "task_definition_arn" {
  type        = string
  description = "The task definition to use for the service."
}

variable "desired_count" {
  type        = number
  description = "Number of desired tasks."
  default     = 1
}

variable "alb_sg_id" {
  type        = string
  description = "Security group ID of the ALB to allow inbound traffic from."
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the target group to register the service with."
}

variable "container_name" {
  type        = string
  description = "Name of the container for the service."
}

variable "container_port" {
  type        = number
  description = "Port on the container to direct traffic to."
}

variable "subnets" {
  type        = list(string)
  description = "List of subnet IDs for the ECS service."
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}