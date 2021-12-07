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

data "aws_iam_policy_document" "devsecops_factory_cloudtrail_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "devsecops_factory_cloudwatch_event_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "devsecops_factory_cloudtrail_access" {
  statement {
    sid    = "${local.devsecops_factory_name_iam}CloudTrailAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.devsecops_factory_cloudtrail_log_group.arn}"]
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

data "aws_iam_policy_document" "devsecops_factory_sast_access" {
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:*",
      "s3:*",
      "cloudformation:*",
      "cloudwatch:*",
      "cloudtrail:*",
      "codebuild:*",
      "codecommit:*",
      "codepipeline:*",
      "ssm:*",
      "lambda:*",
      "kms:*",
      "ecr:*",
      "eks:DescribeCluster"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "devsecops_factory_codepipeline_access" {
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*",
      "logs:*",
      "kms:*",
      "ecr:*"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:ListFunctions",
      "lambda:CreateFunction",
      "lambda:UpdateFunctionConfiguration",
      "lambda:UpdateFunctionCode",
      "lambda:TagResource",
      "lambda:PublishVersion",
      "lambda:GetFunctionConfiguration",
      "lambda:GetFunction"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "devsecops_factory_cloudwatch_event_access" {
  statement {
    sid       = "${local.devsecops_factory_name_iam}CloudWatchEventAccess"
    effect    = "Allow"
    actions   = ["codepipeline:StartPipelineExecution"]
    resources = ["${aws_codepipeline.devsecops_factory_codepipeline.arn}"]
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
        "${aws_iam_role.devsecops_factory_codepipeline_role.arn}",
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

resource "aws_iam_policy" "devsecops_factory_cloudwatch_event_access" {
  name        = "${var.devsecops_factory_name}-cloudwatch-event-policy"
  description = "Policy for ${var.devsecops_factory_name}-cloudwatch-event access"
  policy      = data.aws_iam_policy_document.devsecops_factory_cloudwatch_event_access.json
}

resource "aws_iam_policy" "devsecops_factory_sast_access" {
  name        = "${var.devsecops_factory_name}-sast-policy"
  description = "Policy for ${var.devsecops_factory_name}-sast access"
  policy      = data.aws_iam_policy_document.devsecops_factory_sast_access.json
}

resource "aws_iam_policy" "devsecops_factory_cloudtrail_access" {
  name        = "${var.devsecops_factory_name}-cloudtrail-policy"
  description = "Policy for ${var.devsecops_factory_name}-cloudtrail access"
  policy      = data.aws_iam_policy_document.devsecops_factory_cloudtrail_access.json
}

resource "aws_iam_policy" "devsecops_factory_codepipeline_access" {
  name        = "${var.devsecops_factory_name}-codepipeline-policy"
  description = "Policy for ${var.devsecops_factory_name}-codepipeline access"
  policy      = data.aws_iam_policy_document.devsecops_factory_codepipeline_access.json
}

resource "aws_iam_role_policy_attachment" "devsecops_factory_basic_lambda" {
  role       = aws_iam_role.devsecops_factory_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "devsecops_factory_lambda_access_policies" {
  role       = aws_iam_role.devsecops_factory_lambda_role.name
  policy_arn = aws_iam_policy.devsecops_factory_lambda_access.arn
}

resource "aws_iam_role_policy_attachment" "devsecops_factory_cloudwatch_event_access_policies" {
  role       = aws_iam_role.devsecops_factory_cloudwatch_event_role.name
  policy_arn = aws_iam_policy.devsecops_factory_cloudwatch_event_access.arn
}

resource "aws_iam_role_policy_attachment" "devsecops_factory_sast_access_policies" {
  role       = aws_iam_role.devsecops_factory_sast_role.name
  policy_arn = aws_iam_policy.devsecops_factory_sast_access.arn
}

resource "aws_iam_role_policy_attachment" "devsecops_factory_cloudtrail_access_policies" {
  role       = aws_iam_role.devsecops_factory_cloudtrail_role.name
  policy_arn = aws_iam_policy.devsecops_factory_cloudtrail_access.arn
}

resource "aws_iam_role_policy_attachment" "devsecops_factory_codepipeline_access_policies" {
  role       = aws_iam_role.devsecops_factory_codepipeline_role.name
  policy_arn = aws_iam_policy.devsecops_factory_codepipeline_access.arn
}

resource "aws_iam_role" "devsecops_factory_codepipeline_role" {
  name               = "${var.devsecops_factory_name}-codepipeline-role"
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

resource "aws_iam_role" "devsecops_factory_cloudtrail_role" {
  name               = "${var.devsecops_factory_name}-cloudtrail-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.devsecops_factory_cloudtrail_policy.json
}

resource "aws_iam_role" "devsecops_factory_cloudwatch_event_role" {
  name               = "${var.devsecops_factory_name}-cloudwatch-event-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.devsecops_factory_cloudwatch_event_policy.json
}