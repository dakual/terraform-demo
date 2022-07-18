variable "region" {
  type        = string
  description = "The AWS region name to create/manage resources in"
  default     = "eu-west-2"
}

variable "bucket_prefix" {
  type        = string
  description = "The prefix to use for the S3 bucket name"
  default     = "daghan"
}

variable "upload_source" {
  type        = string
  description = "The source file to upload"
  default     = "uploads/test-1.txt"
}

variable "iam_username" {
  type        = string
  description = "The IAM username to use"
  default     = "terraform"
}