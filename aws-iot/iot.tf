data "aws_iot_endpoint" "iot" {
  endpoint_type = "iot:Data-ATS"
}

resource "aws_iot_thing" "iot" {
  name = "myIot"
}

resource "aws_iot_certificate" "cert" {
  active = true
}

resource "aws_iot_thing_principal_attachment" "att" {
  principal = aws_iot_certificate.cert.arn
  thing     = aws_iot_thing.iot.name
}

resource "aws_iot_policy" "pubsub" {
  name = "iot-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iot:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iot_policy_attachment" "att" {
  policy = aws_iot_policy.pubsub.name
  target = aws_iot_certificate.cert.arn
}

#save certificate files

resource "local_file" "certificate" {
  content  = "${aws_iot_certificate.cert.certificate_pem}"
  filename = "${path.module}/certs/certificate.pem.crt"
}

resource "local_file" "publickey" {
  content  = "${aws_iot_certificate.cert.public_key}"
  filename = "${path.module}/certs/public.pem.key"
}

resource "local_file" "privatekey" {
  content  = "${aws_iot_certificate.cert.private_key}"
  filename = "${path.module}/certs/private.pem.key"
}
