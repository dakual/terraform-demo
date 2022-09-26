variable "region" {
  type        = string
  description = "The AWS region name to create/manage resources in"
  default     = "eu-central-1"
}

variable "outputs_path" {
  type = string
  default = "/home/daghan/Genel/terraform/aws-iot/certs"
}