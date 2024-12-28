resource "aws_vpc" "this_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = var.name
  }
}

resource "aws_internet_gateway" "this_internet_gateway" {
  vpc_id = aws_vpc.this_vpc.id
  tags = {
    Name = "${var.name}_internet_gateway"
  }
}