# Terraform S3 - creating a bucket
resource "aws_s3_bucket" "t1_s3_bucket" {
  bucket = "t1-s3-bucket"
  force_destroy = true
  
  tags   = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.t1_s3_bucket.id
  acl    = "public-read"
}

# Creating an S3 object
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.t1_s3_bucket.id

  for_each = fileset("uploads/", "*")
  key     = each.value
  source  = "uploads/${each.value}"
  etag    = filemd5("uploads/${each.value}")
  acl     = "public-read"

  depends_on = [
    aws_s3_bucket.t1_s3_bucket
  ]
}