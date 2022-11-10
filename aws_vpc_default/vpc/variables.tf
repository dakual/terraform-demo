variable "name" {
  description = "The name of our application."
  default     = "demo"
}

variable "environment" {
  description = "The name of our environment."
  default     = "test"
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "A list of CIDRs for private subnets"
  default     = ["10.0.0.0/20", "10.0.32.0/20", "10.0.64.0/20"]
}

variable "public_subnets" {
  description = "A list of CIDRs for public subnets."
  default     = ["10.0.16.0/20", "10.0.48.0/20", "10.0.80.0/20"]
}

variable "availability_zones" {
  description = "Defaults to all AZ of the region"
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}
