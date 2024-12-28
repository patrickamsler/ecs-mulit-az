output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "A list of IDs for all public subnets"
  value       = [for subnet in module.public_subnets : subnet.subnet_id]
}

output "private_subnet_ids" {
  description = "A list of IDs for all private subnets"
  value       = [for subnet in module.private_subnets : subnet.subnet_id]
}

output "nat_gateway_ids" {
  description = "A list of NAT Gateway IDs associated with the public subnets"
  value       = [for subnet in module.public_subnets : subnet.nat_gw_id]
}