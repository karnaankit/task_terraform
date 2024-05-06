data "aws_s3_bucket" "bucket" {
  bucket = "ankit-s3-bucket-testing"
}

data "aws_caller_identity" "current" {
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "origin access identity for s3 bucket"
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.bucket.arn}/*",
      data.aws_s3_bucket.bucket.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      data.aws_s3_bucket.bucket.arn,
      "${data.aws_s3_bucket.bucket.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = data.aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_cloudfront_distribution" "s3" {
  tags = {
    Name = "ankit-cloudfront-distribution"
  }

  origin {
    domain_name = data.aws_s3_bucket.bucket.bucket_domain_name
    origin_id   = data.aws_s3_bucket.bucket.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Ankit's S3 bucket distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = data.aws_s3_bucket.bucket.id

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

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}