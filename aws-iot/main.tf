variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "iot-things" {
  type = set(string)

  default = [
    "device-1"
  ]
}

data "aws_iot_endpoint" "iot" {
  endpoint_type = "iot:Data-ATS"
}

output "iot_endpoint" {
  value = data.aws_iot_endpoint.iot.endpoint_address
}

module "iot-devices" {
  for_each         = var.iot-things
  source           = "./iot"
  hostname         = each.key
  certificate_path = "${path.module}/certs/"
}



