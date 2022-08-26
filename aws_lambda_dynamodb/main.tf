data "archive_file" "app" {
  type = "zip"

  source_dir  = "${path.module}/app"
  output_path = "${path.module}/app.zip"
}

data "aws_caller_identity" "aws_id" {}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy" "dynamodb-lambda-policy" {
   name = "dynamodb_lambda_policy"
   role = aws_iam_role.lambda_exec.id
   
   policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
           "Effect" : "Allow",
           "Action" : [
              "dynamodb:BatchGetItem",
              "dynamodb:GetItem",
              "dynamodb:Query",
              "dynamodb:Scan",
              "dynamodb:BatchWriteItem",
              "dynamodb:PutItem",
              "dynamodb:UpdateItem"            
           ],
           "Resource" : "${aws_dynamodb_table.items.arn}"
        }
      ]
   })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = "${var.bucket_name}-${data.aws_caller_identity.aws_id.account_id}"
  force_destroy = true
  
  tags = {
    Name        = "App bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "lambda_app" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "app.zip"
  source = data.archive_file.app.output_path
  etag   = filemd5(data.archive_file.app.output_path)  
}

resource "aws_s3_bucket_acl" "lambda_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

resource "aws_lambda_function" "myapp" {
  function_name     = "MyApp"
  s3_bucket         = aws_s3_bucket.lambda_bucket.id
  s3_key            = aws_s3_object.lambda_app.key
  runtime           = "nodejs14.x"
  handler           = "index.handler"
  source_code_hash  = data.archive_file.app.output_base64sha256
  role              = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.myapp.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

resource "aws_apigatewayv2_api" "lambda" {
  name          = "myapp_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id      = aws_apigatewayv2_api.lambda.id
  name        = "stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "myapp" {
  api_id = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.myapp.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "myapp_1" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "GET /items"
  target    = "integrations/${aws_apigatewayv2_integration.myapp.id}"
}

resource "aws_apigatewayv2_route" "myapp_2" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "GET /items/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.myapp.id}"
}

resource "aws_apigatewayv2_route" "myapp_3" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "PUT /items"
  target    = "integrations/${aws_apigatewayv2_integration.myapp.id}"
}

resource "aws_apigatewayv2_route" "myapp_4" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "DELETE /items/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.myapp.id}"
}

resource "aws_dynamodb_table" "items" {
  name           = "myTable"
  hash_key       = "id"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_cloudwatch_log_group" "myapp" {
  name = "/aws/lambda/${aws_lambda_function.myapp.function_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"
  retention_in_days = 30
}