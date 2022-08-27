data "archive_file" "app" {
  type = "zip"

  source_dir  = "${path.module}/app"
  output_path = "${path.module}/app.zip"
}

resource "aws_sns_topic" "user_updates" {
  name = "my-topic"
}

resource "aws_sqs_queue" "user_updates_queue" {
  name                      = "my-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.user_queue_deadletter.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "user_queue_deadletter" {
  name = "my-deadletter-queue"
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.user_updates_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.user_updates_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.user_updates.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.user_updates_queue.arn
}


resource "aws_iam_role" "lambda_role" {
  name = "LambdaRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_role_logs_policy" {
  name = "LambdaRolePolicy"
  role = aws_iam_role.lambda_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_role_sqs_policy" {
  name = "AllowSQSPermissions"
  role = aws_iam_role.lambda_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:ChangeMessageVisibility",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ReceiveMessage"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_lambda_function" "myapp" {
  function_name     = "MyApp"
  filename          = "${path.module}/app.zip"
  runtime           = "nodejs14.x"
  handler           = "index.handler"
  source_code_hash  = data.archive_file.app.output_base64sha256
  role              = aws_iam_role.lambda_role.arn

  environment {
      variables = {
          foo = "bar"
      }
  }
}

resource "aws_lambda_event_source_mapping" "user_updates_lambda_event_source" {
    event_source_arn = aws_sqs_queue.user_updates_queue.arn
    function_name    = aws_lambda_function.myapp.arn
    batch_size       = 1
}
