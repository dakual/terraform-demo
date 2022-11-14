variable "environment" {
  type        = string
  description = "The name of the Enviroment"
  default     = "dev"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
  default     = "eks-demo"
}

variable "cluster_version" {
  type        = string
  description = "The version of the cluster"
  default     = "1.23"
}

variable "region" {
  type        = string
  description = "AWS region to launch servers."
  default     = "eu-central-1"
}
