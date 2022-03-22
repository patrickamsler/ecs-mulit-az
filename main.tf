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