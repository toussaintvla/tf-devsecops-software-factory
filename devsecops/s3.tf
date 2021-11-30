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
  policy = data.aws_iam_policy_document.devsecops_factory_artifacts_bucket_access.json
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
  policy = data.aws_iam_policy_document.devsecops_factory_cloudtrail_bucket_access.json
}