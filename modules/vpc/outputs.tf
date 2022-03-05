output "vpc_id" {
  value = aws_vpc.this_vpc.id
}

output "igw_id" {
  value = aws_internet_gateway.this_internet_gateway.id
}