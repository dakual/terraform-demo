resource "aws_lambda_function" "app" {
  function_name = "MyApp"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_app.key

  runtime = "nodejs14.x"
  handler = "hello.handler"

  source_code_hash = data.archive_file.app.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}