# Create an ECR Repository
resource "aws_ecr_repository" "ecr_repo" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE" # Optional: Set to "IMMUTABLE" for stricter versioning
  image_scanning_configuration {
    // When set to true, each image pushed to the repository will be scanned for
    // known vulnerabilities, providing an additional layer of security.
    scan_on_push = var.image_scan_on_push
  }
}