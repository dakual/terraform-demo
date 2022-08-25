resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = "${var.bucket_name}-${data.aws_caller_identity.aws_id.account_id}"
  force_destroy = true
  
  tags = {
    Name        = "App bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "lambda_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

resource "aws_s3_object" "lambda_app" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "app.zip"
  source = data.archive_file.app.output_path

  etag = filemd5(data.archive_file.app.output_path)  
}