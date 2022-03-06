provider "aws" {
  profile = "patrick-private"
  region  = var.region
  default_tags {
    tags = {
      Environment = "Test"
      Owner = "Patrick"
    }
  }
}

// create the cluster
resource "aws_ecs_cluster" "tf-demo-ecs-cluster" {
  name = "tf-demo-cluster"
}