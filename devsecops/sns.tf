resource "aws_sns_topic" "devsecops_factory_approval_topic" {
  name              = "${var.devsecops_factory_name}-approval-topic"
  display_name      = "${var.devsecops_factory_name}-approval-topic"
  kms_master_key_id = "alias/aws/sns"
  tags = {
    pipeline-name = "${var.devsecops_factory_name}-pipeline"
  }
}

resource "aws_sns_topic" "devsecops_factory_pipeline_topic" {
  name              = "${var.devsecops_factory_name}-pipeline-topic"
  display_name      = "${var.devsecops_factory_name}-pipeline-topic"
  kms_master_key_id = "alias/aws/sns"
  tags = {
    pipeline-name = "${var.devsecops_factory_name}-pipeline"
  }
}

resource "aws_sns_topic" "devsecops_factory_cloudtrail_topic" {
  name              = "${var.devsecops_factory_name}-cloudtrail-topic"
  display_name      = "${var.devsecops_factory_name}-cloudtrail-topic"
  kms_master_key_id = "alias/aws/sns"
  tags = {
    pipeline-name = "${var.devsecops_factory_name}-pipeline"
  }
}

resource "aws_sns_topic_policy" "devsecops_factory_approval_topic_policy" {
  arn    = aws_sns_topic.devsecops_factory_approval_topic.arn
  policy = data.aws_iam_policy_document.devsecops_factory_topic_policy.json
}

resource "aws_sns_topic_policy" "devsecops_factory_pipeline_topic_policy" {
  arn    = aws_sns_topic.devsecops_factory_pipeline_topic.arn
  policy = data.aws_iam_policy_document.devsecops_factory_topic_policy.json
}

resource "aws_sns_topic_policy" "devsecops_factory_cloudtrail_topic_policy" {
  arn    = aws_sns_topic.devsecops_factory_cloudtrail_topic.arn
  policy = data.aws_iam_policy_document.devsecops_factory_topic_policy.json
}

data "aws_iam_policy_document" "devsecops_factory_topic_policy" {
  statement {
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = ["${aws_sns_topic.devsecops_factory_approval_topic.arn}"]
    condition {
      test     = "StringEquals"
      variable = "aws:sourceowner"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_sns_topic_subscription" "devsecops_factory_approval_target" {
  topic_arn = aws_sns_topic.devsecops_factory_approval_topic.arn
  protocol  = "email"
  endpoint  = var.pipeline_approver_email
}

resource "aws_sns_topic_subscription" "devsecops_factory_pipeline_target" {
  topic_arn = aws_sns_topic.devsecops_factory_pipeline_topic.arn
  protocol  = "email"
  endpoint  = var.pipeline_notifications_email
}

resource "aws_sns_topic_subscription" "devsecops_factory_cloudtrail_target" {
  topic_arn = aws_sns_topic.devsecops_factory_cloudtrail_topic.arn
  protocol  = "email"
  endpoint  = var.pipeline_notifications_email
}