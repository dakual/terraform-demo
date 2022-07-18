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