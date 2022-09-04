variable aws_region {
  type        = string
  default     = "eu-central-1"
  description = "AWS region for all resources."
}

variable application_name {
  type    = string
  default = "myapp"
}

variable vpc_id {
  type    = string
  default = "vpc-064f43e135e1ecbc0"
}

variable vpc_subnets {
  type = list(string)
  default = ["subnet-02caf3f4a7dab08f6","subnet-0e00855f4313be466","subnet-0535e60978084785d"]
}

variable ssh_key {
  type    = string
  default = "mykey"
}

variable vpc_cidr {
  type    = string
  default = "0.0.0.0/0"
}