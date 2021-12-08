resource "aws_s3_bucket" "devsecops_factory_artifacts_bucket" {
  bucket = local.devsecops_artifacts_bucket
  acl    = "private"

  tags = {
    pipeline-name = "${var.devsecops_factory_name}-pipeline"
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

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "ArtifactsPolicy",
    "Statement": [
       {
          "Sid":"DenyUnEncryptedObjectUploads",
          "Effect":"Deny",
          "Principal":"*",
          "Action":"s3:PutObject",
          "Resource":[
             "arn:aws:s3:::${local.devsecops_artifacts_bucket}/*"
          ],
          "Condition":{
             "StringNotEquals":{
                "s3:x-amz-server-side-encryption":"aws:kms"
             }
          }
       },
       {
          "Sid":"DenyInsecureConnections",
          "Effect":"Deny",
          "Principal":"*",
          "Action":"s3:*",
          "Resource":[
             "arn:aws:s3:::${local.devsecops_artifacts_bucket}/*"
          ],
          "Condition":{
             "Bool":{
                "aws:SecureTransport":false
             }
          }
       }
    ]
}
POLICY
}
