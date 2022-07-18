# IAM Policy - to list all S3 buckets in the account - to be attached to the created user

data "aws_iam_policy_document" "s3_list" {
  statement {
    sid    = "ListS3Buckets"
    effect = "Allow"

    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"] # List all S3 buckets in the account
  }
}

# S3 Bucket Policy -  to allow access to a particular bucket's objects - to be attached to bucket
data "aws_iam_policy_document" "bucket_policy_document" {
  statement {
    sid = "SidToOverride"

    actions   = ["s3:*"]
    resources = ["*"]
  }
}