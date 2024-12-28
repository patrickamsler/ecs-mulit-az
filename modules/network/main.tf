# VPC
module "vpc" {
  source     = "./modules/vpc"
  name       = "${var.name}-vpc"
  vpc_cidr   = var.vpc_cidr
}

# Public Subnets
module "public_subnets" {
  for_each = var.public_subnets

  source             = "./modules/public_subnet"
  name               = "${var.name}-${each.key}"
  vpc_id             = module.vpc.vpc_id
  subnet_cidr_block  = each.value.cidr
  az                 = "${var.region}${each.value.az}"
  igw_id             = module.vpc.igw_id
}

# Private Subnets
module "private_subnets" {
  for_each = var.private_subnets

  source             = "./modules/private_subnet"
  name               = "${var.name}-${each.key}"
  vpc_id             = module.vpc.vpc_id
  subnet_cidr_block  = each.value.cidr
  az                 = "${var.region}${each.value.az}"
  nat_gw_id          = lookup(module.public_subnets, "public-${each.value.az}").nat_gw_id
}