variable "region" {
  type        = string
  description = "The AWS region name to create/manage resources in"
  default     = "eu-west-2"
}

variable key_name {
  default     = "access_key"
  type        = string
}

variable "vpc_id" {
  type    = string
  default = "vpc-0e9f863b6a9da703f"
}

variable "puppet_mastername" {
  type    = string
  default = "puppet"
}

variable "puppet_agentname" {
  type    = string
  default = "agent"
}

variable "puppet_repository" {
  type    = string
  default = "https://apt.puppetlabs.com/puppet6-release-focal.deb"
}