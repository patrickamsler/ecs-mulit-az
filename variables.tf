variable "profile" {
  description = "AWS profile to use."
  type        = string
  default     = "default" # Replace with your aws profile
}

variable "owner" {
  description = "Owner of the resources."
  type        = string
  default     = "terraform" # Replace with your team name
}

variable "environment" {
  description = "Environment for the resources."
  type        = string
  default     = "test" # Replace with your environment e.g. dev, prod
}

variable "region" {
  description = "AWS region to launch servers."
  type        = string
  default     = "eu-central-1" # Replace with your region
}

variable "name" {
  description = "Base name for the project or resources."
  type        = string
  default     = "ecs-terraform-demo" # Replace with your project name
}