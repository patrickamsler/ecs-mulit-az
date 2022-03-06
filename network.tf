module "tf_demo_vpc" {
  source = "./modules/vpc"
  name = "tf-demo-aws-vpc"
  vpc_cidr = "10.0.0.0/16" // 10.0.0.0 - 10.0.255.255
}

module "public_subnet_a" {
  source = "./modules/public_subnet"
  name = "tf-demo-public-subnet-a"
  vpc_id = module.tf_demo_vpc.vpc_id
  subnet_cidr_block = "10.0.0.0/24" // 251 public addresses
  az = "${var.region}a"
  igw_id = module.tf_demo_vpc.igw_id // vpc internet gateway
}

module "public_subnet_b" {
  source = "./modules/public_subnet"
  name = "tf-demo-public-subnet-b"
  vpc_id = module.tf_demo_vpc.vpc_id
  subnet_cidr_block = "10.0.1.0/24" // 251 public addresses
  az = "${var.region}b"
  igw_id = module.tf_demo_vpc.igw_id // vpc internet gateway
}

module "private_subnet_a" {
  source = "./modules/private_subnet"
  name = "tf-demo-private-subnet-a"
  vpc_id = module.tf_demo_vpc.vpc_id
  subnet_cidr_block = "10.0.16.0/20" // 4091 private addresses
  az = "${var.region}a"
  nat_gw_id = module.public_subnet_a.nat_gw_id // nat gateway in public subnet a
}

module "private_subnet_b" {
  source = "./modules/private_subnet"
  name = "tf-demo-private-subnet-b"
  vpc_id = module.tf_demo_vpc.vpc_id
  subnet_cidr_block = "10.0.32.0/20" // 4091 private addresses
  az = "${var.region}b"
  nat_gw_id = module.public_subnet_b.nat_gw_id // nat gateway in public subnet b
}