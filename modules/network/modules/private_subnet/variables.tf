variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_cidr_block" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "az" {
  description = "Availability zone for the private subnet"
  type        = string
}

variable "nat_gw_id" {
  description = "ID of the NAT Gateway"
  type        = string
}

variable "name" {
  description = "Name of the private subnet"
  type        = string
}