variable "name" {
  description = "Name of the subnet"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "igw_id" {
  description = "The ID of the internet gateway"
}

variable "az" {
  description = "Availability Zone"
}

variable "subnet_cidr_block" {
  description = "Subnet CIDR block"
}