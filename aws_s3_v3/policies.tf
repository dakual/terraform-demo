# IAM Policy - to list all S3 buckets in the account - to be attached to the created user

data "aws_iam_policy_document" "s3_list" {
  statement {
    sid    = "ListS3Buckets"
    effect = "Allow"

    actions   = ["s3:*"]
    resources = ["*"] # List all S3 buckets in the account
  }
}
