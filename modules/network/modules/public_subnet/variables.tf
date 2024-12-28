variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "az" {
  description = "Availability zone for the public subnet"
  type        = string
}

variable "igw_id" {
  description = "ID of the Internet Gateway"
  type        = string
}

variable "name" {
  description = "Name of the public subnet"
  type        = string
}