resource "aws_s3_bucket" "bucket" {
  bucket = "ankit-s3-bucket-testing"
}

resource "aws_s3_bucket_policy" "default" {
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
  bucket = aws_s3_bucket.bucket.id
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}