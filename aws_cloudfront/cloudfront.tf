data "aws_caller_identity" "aws_id" {}

resource "aws_s3_bucket" "b" {
  bucket = "${var.bucket_name}-${data.aws_caller_identity.aws_id.account_id}"
  acl    = "public-read"
  force_destroy = true

  tags = {
    Name = "My bucket"
  }
}

# resource "aws_s3_bucket_acl" "b_acl" {
#   bucket = aws_s3_bucket.b.id
#   acl    = "public-read"
# }

resource "aws_s3_object" "o_obj_1" {
  bucket = aws_s3_bucket.b.id
#  acl    = "public-read"
  key    = "404.html"
  source = "${path.module}/404.html"
  etag   = filemd5("${path.module}/404.html")
}

resource "aws_s3_object" "o_obj_2" {
  bucket = aws_s3_bucket.b.id
#  acl    = "public-read"
  key    = "index.html"
  source = "${path.module}/index.html"
  etag   = filemd5("${path.module}/index.html")
}

locals {
  s3_origin_id = "my-origin"
}

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "Some comment"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.b.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }
  
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.b.bucket_domain_name
    prefix          = "myprefix"
  }

  custom_error_response {
    error_caching_min_ttl = 30
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations = []
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}