data "aws_iam_policy_document" "devsecops_factory_lambda_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "devsecops_factory_codepipeline_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "devsecops_factory_sast_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "devsecops_factory_lambda_access" {
  statement {
    sid    = "${local.devsecops_factory_name_iam}LambdaAccess"
    effect = "Allow"
    actions = [
      "logs:*",
      "s3:*",
      "securityhub:*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "devsecops_factory_pipeline_key_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    effect = "Allow"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }
  statement {
    principals {
      type = "Service"
      identifiers = [
        "codepipeline.amazonaws.com",
        "logs.${var.region}.amazonaws.com",
        "codebuild.amazonaws.com"
      ]
    }
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
  statement {
    principals {
      type = "AWS"
      identifiers = [
        "${aws_iam_role.devsecops_factory_pipeline_role.arn}",
        "${aws_iam_role.devsecops_factory_sast_role.arn}"
      ]
    }
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "devsecops_factory_lambda_access" {
  name        = "${var.devsecops_factory_name}-lambda-policy"
  description = "Policy for ${var.devsecops_factory_name}-lambda access"
  policy      = data.aws_iam_policy_document.devsecops_factory_lambda_access.json
}

resource "aws_iam_policy" "devsecops_factory_pipeline_key_access" {
  name        = "${var.devsecops_factory_name}-key-policy"
  description = "Policy for ${var.devsecops_factory_name}-key access"
  policy      = data.aws_iam_policy_document.devsecops_factory_pipeline_key_access.json
}

resource "aws_iam_role_policy_attachment" "devsecops_factory_basic_lambda" {
  role       = aws_iam_role.devsecops_factory_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "devsecops_factory_access_policies" {
  role       = aws_iam_role.devsecops_factory_lambda_role.name
  policy_arn = aws_iam_policy.devsecops_factory_lambda_access.arn
}

resource "aws_iam_role" "devsecops_factory_pipeline_role" {
  name               = "${var.devsecops_factory_name}-pipeline-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.devsecops_factory_codepipeline_policy.json
}

resource "aws_iam_role" "devsecops_factory_sast_role" {
  name               = "${var.devsecops_factory_name}-sast-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.devsecops_factory_sast_policy.json
}

resource "aws_iam_role" "devsecops_factory_lambda_role" {
  name               = "${var.devsecops_factory_name}-lambda-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.devsecops_factory_lambda_policy.json
}