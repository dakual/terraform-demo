resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.t1_s3_bucket.bucket_regional_domain_name}"
    origin_id   = "${aws_s3_bucket.t1_s3_bucket.id}"
	
      custom_origin_config {
        http_port   = 80
        https_port  = 443
        origin_protocol_policy  = "match-viewer"
        origin_ssl_protocols    = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  price_class         = "PriceClass_200"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.t1_s3_bucket.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "IN"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}