# creates the KMS key setting deletion_window_in_days to 10 and turning on key rotation.
resource "aws_kms_key" "terraform-bucket-key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

# provides an alias for the generated key. This alias will later be referenced in the 
# backend resource to come.
resource "aws_kms_alias" "key-alias" {
  name          = "alias/terraform-bucket-key"
  target_key_id = aws_kms_key.terraform-bucket-key.key_id
}

# creates the required bucket with a few essential security features. We turn versioning 
# on and server-side encryption using the KMS key we generated previously.
resource "aws_s3_bucket" "terraform-state" {
  bucket = "dakual-terraform-state"

  tags = {
    Name        = "Terraform state bucket"
    Environment = "Development-1"
  }
}

# enable versioning feature
resource "aws_s3_bucket_versioning" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# creating essential security features.
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform-bucket-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# guarantees that the bucket is not publicly accessible.
resource "aws_s3_bucket_acl" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id
  acl    = "private"
}

# To prevent two team members from writing to the state file at the same time, 
# we will implement a DynamoDB table lock.
resource "aws_dynamodb_table" "terraform-state" {
  name           = "terraform-state"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}