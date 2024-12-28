variable "ecr_name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "image_scan_on_push" {
  description = "Enable image scanning on push. "
  type        = bool
  default     = true
}