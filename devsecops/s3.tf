resource "aws_s3_bucket" "devsecops_factory_artifacts_bucket" {
  bucket = local.devsecops_artifacts_bucket
  acl    = "private"

  tags = {
    pipeline-name = var.devsecops_factory_name
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "expire"
    prefix  = "/"
    enabled = true

    transition {
      storage_class = "INTELLIGENT_TIERING"
    }
    noncurrent_version_transition {
      storage_class = "INTELLIGENT_TIERING"
    }
    expiration {
      days = 2190
    }
    noncurrent_version_expiration {
      days = 2190
    }
  }
}

resource "aws_s3_bucket_policy" "devsecops_factory_artifacts_bucket_policy" {
  bucket = aws_s3_bucket.devsecops_factory_artifacts_bucket.id
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Id      = "ArtifactsPolicy"
      Statement = [
        {
          Sid       = "DenyUnEncryptedObjectUploads"
          Effect    = "Deny"
          Principal = "*"
          Action    = "s3:PutObject"
          Resource  = ["${aws_s3_bucket.devsecops_factory_artifacts_bucket.arn}/*"]
          Condition = {
            StringNotEquals = {
              "s3:x-amz-server-side-encryption" = "aws:kms"
            }
          }
        },
        {
          Sid       = "DenyInsecureConnections"
          Effect    = "Deny"
          Principal = "*"
          Action    = "s3:*"
          Resource  = ["${aws_s3_bucket.devsecops_factory_artifacts_bucket.arn}/*"]
          Condition = {
            Bool = {
              "aws:SecureTransport" = false
            }
          }
        }
      ]
  })
}

resource "aws_s3_bucket" "devsecops_factory_cloudtrail_bucket" {
  bucket = local.devsecops_cloudtrail_bucket
  acl    = "private"

  tags = {
    pipeline-name = var.devsecops_factory_name
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "expire"
    prefix  = "/"
    enabled = true

    transition {
      storage_class = "INTELLIGENT_TIERING"
    }
    noncurrent_version_transition {
      storage_class = "INTELLIGENT_TIERING"
    }
    expiration {
      days = 2190
    }
    noncurrent_version_expiration {
      days = 2190
    }
  }
}

resource "aws_s3_bucket_policy" "devsecops_factory_cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.devsecops_factory_cloudtrail_bucket.id
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Id      = "CloudTrailPolicy"
      Statement = [
        {
          Sid    = "AWSCloudTrailAclCheck"
          Effect = "Allow"
          Principal = {
            Service = "cloudtrail.amazonaws.com"
          }
          Action   = "s3:GetBucketAcl"
          Resource = ["${aws_s3_bucket.devsecops_factory_cloudtrail_bucket.arn}"]
        },
        {
          Sid    = "AWSCloudTrailWrite"
          Effect = "Allow"
          Principal = {
            Service = "cloudtrail.amazonaws.com"
          }
          Action   = "s3:PutObject"
          Resource = ["${aws_s3_bucket.devsecops_factory_cloudtrail_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
          Condition = {
            StringNotEquals = {
              "s3:x-amz-acl" = "bucket-owner-full-control"
            }
          }
        },
        {
          Sid       = "AllowSSLRequestsOnly"
          Effect    = "Deny"
          Principal = "*"
          Action    = "s3:*"
          Resource  = ["${aws_s3_bucket.devsecops_factory_cloudtrail_bucket.arn}/*"]
          Condition = {
            Bool = {
              "aws:SecureTransport" = false
            }
          }
        }
      ]
  })
}