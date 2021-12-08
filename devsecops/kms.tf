resource "aws_kms_key" "devsecops_factory_kms_key" {
  description         = "KMS key for pipeline"
  is_enabled          = true
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.devsecops_factory_pipeline_key_access.json
  tags = {
    pipeline-name = "${var.devsecops_factory_name}-pipeline"
  }
}