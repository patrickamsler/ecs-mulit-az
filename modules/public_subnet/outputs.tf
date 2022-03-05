output "id" {
  value = aws_subnet.this_subnet.id
}

output "nat_gw_id" {
  value = aws_nat_gateway.nat_gw.id
}