# variable "service_name" {
#   description = "The name of the ECS service"
#   type        = string
# }
#
# variable "cluster_arn" {
#   description = "The ARN of the ECS cluster where the service will run"
#   type        = string
# }
#
# variable "task_definition_arn" {
#   description = "The ARN of the task definition to use for the service"
#   type        = string
# }
#
# variable "desired_count" {
#   description = "The desired number of tasks to run"
#   type        = number
#   default     = 1
# }
#
# variable "launch_type" {
#   description = "The launch type to use (FARGATE or EC2)"
#   type        = string
#   default     = "FARGATE"
# }
#
# variable "load_balancer" {
#   description = "Optional load balancer configuration for the service"
#   type = object({
#     target_group_arn = string
#     container_name   = string
#     container_port   = number
#   })
#   default = null
# }
#
# variable "network_configuration" {
#   description = "Optional network configuration for the service"
#   type = object({
#     subnets         = list(string)
#     security_groups = list(string)
#     assign_public_ip = string
#   })
#   default = null
# }
#
# variable "deployment_controller" {
#   description = "Type of deployment controller (ECS by default)"
#   type        = string
#   default     = "ECS"
# }