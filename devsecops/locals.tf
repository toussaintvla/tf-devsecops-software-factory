locals {
  devsecops_factory_name_iam = replace(var.devsecops_factory_name, "/[^a-zA-Z0-9 ]/", "")
  devsecops_artifacts_bucket = "${var.devsecops_factory_name}.artifacts-${data.aws_caller_identity.current.account_id}-${var.region}"
}