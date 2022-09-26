output "iot_endpoint" {
  value = data.aws_iot_endpoint.iot.endpoint_address
}

output "iot_arn" {
  value = aws_iot_thing.iot.arn
}

