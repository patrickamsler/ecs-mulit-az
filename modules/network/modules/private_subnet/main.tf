resource "aws_subnet" "this_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.az
  map_public_ip_on_launch = false
  tags = {
    Name = var.name
  }
}

resource "aws_route_table" "this_rtb" {
  vpc_id = var.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gw_id
  }
  tags = {
    Name = "${var.name}-route-table"
  }
}

resource "aws_route_table_association" "this_route_table_association" {
  subnet_id      = aws_subnet.this_subnet.id
  route_table_id = aws_route_table.this_rtb.id
}