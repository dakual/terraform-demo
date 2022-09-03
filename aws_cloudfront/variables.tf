variable aws_region {
  type        = string
  default     = "eu-central-1"
  description = "AWS region for all resources."
}

variable bucket_name {
  type    = string
  default = "myapp"
}