resource "aws_s3_bucket" "devsecops_factory_s3_bucket" {
  bucket = local.devsecops_s3_bucket
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