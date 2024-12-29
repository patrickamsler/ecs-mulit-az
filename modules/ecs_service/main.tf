# resource "aws_ecs_service" "this" {
#   name            = var.service_name
#   cluster         = var.cluster_arn
#   task_definition = var.task_definition_arn
#   desired_count   = var.desired_count
#   launch_type     = var.launch_type
#
#   dynamic "load_balancer" {
#     for_each = var.load_balancer != null ? [var.load_balancer] : []
#     content {
#       target_group_arn = load_balancer.value.target_group_arn
#       container_name   = load_balancer.value.container_name
#       container_port   = load_balancer.value.container_port
#     }
#   }
#
#   dynamic "network_configuration" {
#     for_each = var.network_configuration != null ? [var.network_configuration] : []
#     content {
#       subnets         = network_configuration.value.subnets
#       security_groups = network_configuration.value.security_groups
#       assign_public_ip = network_configuration.value.assign_public_ip
#     }
#   }
#
#   deployment_controller {
#     type = var.deployment_controller
#   }
# }