variable "name" {
  description = "Name of the subnet"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "az" {
  description = "Availability Zone"
}

variable "subnet_cidr_block" {
  description = "Subnet CIDR block"
}

variable "nat_gw_id" {
  description = "The ID of the nat gateway from the public subnet"
}