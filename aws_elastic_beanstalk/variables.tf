variable aws_region {
  type    = string
}

variable app_name {
  type    = string
}

variable instance_type {
  type    = string
}

variable tier {
  type    = string
}

variable stack_name {
  type    = string
}

variable vpc_id {
  type    = string
}

variable vpc_subnets {
  type    = list(string)
}

variable ssh_key {
  type    = string
}

variable vpc_cidr {
  type    = string
}