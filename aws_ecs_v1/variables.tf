variable "region" {
  type        = string
  description = "The AWS region name to create/manage resources in"
  default     = "eu-west-2"
}

variable "cluster_name" {
  type        = string
  default     = "development"
}

variable "image_name" {
  type        = string
  default     = "632296647497.dkr.ecr.eu-west-2.amazonaws.com/py-app"
}

variable "vpc_id" {
  type    = string
  default = "vpc-0e9f863b6a9da703f"
}

variable "security_group_id" {
  type    = string
  default = "sg-0648fcc34957cb542"
}
