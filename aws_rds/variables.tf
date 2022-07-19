variable "region" {
  type        = string
  description = "The AWS region name to create/manage resources in"
  default     = "eu-west-2"
}

variable "db_username" {
  description = "RDS root username"
  type        = string
  default     = "terraform"
}

variable "db_password" {
  description = "RDS root password"
  type        = string
  default     = "terraform"
}