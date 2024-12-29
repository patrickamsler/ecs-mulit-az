variable "alb_name" {
  description = "The name of the ALB"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets where the ALB will be deployed"
  type        = list(string)
}

variable "target_group_name" {
  description = "The name of the target group"
  type        = string
}

variable "target_group_port" {
  description = "The port for the target group"
  type        = number
  default     = 80
}

variable "target_type" {
  description = "The type of targets for the target group (instance, ip, lambda)"
  type        = string
  default     = "ip"
}

variable "health_check_healthy_threshold" {
  description = "The number of consecutive health checks required before considering the target healthy"
  type        = number
  default     = 3
}

variable "health_check_interval" {
  description = "The interval in seconds between health checks"
  type        = number
  default     = 300
}

variable "health_check_protocol" {
  description = "The protocol used for health checks (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"
}

variable "health_check_matcher" {
  description = "The HTTP codes to match for a healthy response"
  type        = string
  default     = "200"
}

variable "health_check_timeout" {
  description = "The time in seconds to wait for a health check response"
  type        = number
  default     = 3
}

variable "health_check_path" {
  description = "The path to use for health checks"
  type        = string
  default     = "/"
}

variable "health_check_unhealthy_threshold" {
  description = "The number of consecutive health check failures before considering the target unhealthy"
  type        = number
  default     = 2
}

variable "listener_port" {
  description = "The port for the ALB listener"
  type        = number
  default     = 80
}