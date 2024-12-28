variable "task_family" {
  description = "The family name of the ECS task definition"
  type        = string
}

variable "container_definitions" {
  description = "JSON-encoded list of container definitions"
  type        = list(any)
}

variable "cpu" {
  description = "The number of CPU units used by the task"
  type        = string
}

variable "memory" {
  description = "The amount of memory used by the task in MiB"
  type        = string
}

variable "requires_compatibilities" {
  description = "A list of launch types required by the task"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "network_mode" {
  description = "The Docker networking mode to use for the containers in the task"
  type        = string
  default     = "awsvpc"
}

variable "create_task_role" {
  description = "Flag to create an IAM task role for accessing AWS services"
  type        = bool
  default     = false
}