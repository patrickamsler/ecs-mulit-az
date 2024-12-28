provider "aws" {
  profile = var.profile
  region  = var.region
  default_tags {
    tags = {
      Environment = var.environment
      Owner = var.owner
    }
  }
}

module "network" {
  source = "./modules/network"
  name   = "${var.name}-network"
  vpc_cidr = "10.0.0.0/16" // IP addresses in the range of 10.0.0.0 to 10.0.255.255 (65,536 addresses)
  region = var.region
  public_subnets = { # public subnet 2x 251 addresses
    public-a = { cidr = "10.0.0.0/24", az = "a" }
    public-b = { cidr = "10.0.1.0/24", az = "b" }
  }
  private_subnets = { # private subnet 2x 4091 addresses
    private-a = { cidr = "10.0.16.0/20", az = "a" }
    private-b = { cidr = "10.0.32.0/20", az = "b" }
  }
}

module "ecr" {
  source   = "./modules/ecr"
  ecr_name = var.name
  image_scan_on_push = false
}
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.ecr_repository_url
}

# // create the cluster
resource "aws_ecs_cluster" "tf-demo-ecs-cluster" {
  name = "tf-demo-cluster"
}