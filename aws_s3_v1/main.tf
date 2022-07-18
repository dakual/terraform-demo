resource "aws_s3_bucket" "bucket" {
  bucket_prefix = var.bucket_prefix

#  object_lock_enabled = true

  tags = {
    "Project" = "hands-on.cloud"
  }
}

# resource "aws_s3_bucket_object_lock_configuration" "bucket" {
#   bucket = aws_s3_bucket.bucket.bucket
#   rule {
#     default_retention {
#       mode = "COMPLIANCE"
#       days = 365
#     }
#   }
# }