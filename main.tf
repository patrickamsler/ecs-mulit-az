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

// create the cluster
resource "aws_ecs_cluster" "tf-demo-ecs-cluster" {
  name = "tf-demo-cluster"
}