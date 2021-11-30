resource "aws_cloudwatch_log_group" "devsecops_factory_pipeline_log_group" {
  name              = "${var.devsecops_factory_name}-pipeline-logs"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "devsecops_factory_cloudtrail_log_group" {
  name              = "${var.devsecops_factory_name}-cloudtrail-logs"
  retention_in_days = 90
}

resource "aws_cloudwatch_event_rule" "devsecops_factory_cloudwatch_event_rule" {
  name          = "${var.devsecops_factory_name}-codepipeline-trigger"
  description   = "Trigger CodePipeline from CodeCommit Repository State Change"
  event_pattern = <<EOF
    {
        "source": [
            "aws.codecommit"
        ],
        "detail-type": [
            "CodeCommit Repository State Change"
        ],
        "resources": [
            "arn:aws:codecommit:${var.region}:${data.aws_caller_identity.current.account_id}:${var.repository_name}"
        ],
        "detail": {
            "event": [
              "referenceCreated",
              "referenceUpdated"
            ],
            "referenceType": [
              "branch"
            ],
            "referenceName": [
              "master"
            ]
        }
    }
EOF
}

resource "aws_cloudwatch_event_target" "devsecops_factory_cloudwatch_event_target" {
  target_id = "${var.devsecops_factory_name}-codepipeline"
  rule      = aws_cloudwatch_event_rule.devsecops_factory_cloudwatch_event_rule.name
  role_arn  = aws_iam_role.devsecops_factory_cloudwatch_event_role.arn
  arn       = aws_codepipeline.devsecops_factory_codepipeline.arn
}

resource "aws_cloudwatch_event_rule" "devsecops_factory_pipeline_event_rule" {
  name          = "${var.devsecops_factory_name}-codepipeline-notifications"
  description   = "Send CodePipeline SNS notifications from CodePipeline Stage Execution State Change"
  role_arn      = aws_iam_role.devsecops_factory_cloudwatch_event_role.arn
  event_pattern = <<EOF
    {
        "source": [
            "aws.codepipeline"
        ],
        "detail-type": [
            "CodePipeline Stage Execution State Change"
        ]
    }
EOF
}

resource "aws_cloudwatch_event_target" "devsecops_factory_pipeline_event_target" {
  target_id = "${var.devsecops_factory_name}-pipeline-notifications"
  rule      = aws_cloudwatch_event_rule.devsecops_factory_pipeline_event_rule.name
  arn       = aws_sns_topic.devsecops_factory_pipeline_topic.arn
}

resource "aws_cloudtrail" "devsecops_factory_cloudtrail" {
  depends_on                 = [aws_s3_bucket_policy.devsecops_factory_cloudtrail_bucket_policy]
  name                       = "${var.devsecops_factory_name}-cloudtrail"
  s3_bucket_name             = aws_s3_bucket.devsecops_factory_artifacts_bucket.id
  cloud_watch_logs_group_arn = aws_cloudwatch_log_group.devsecops_factory_cloudtrail_log_group.arn
  cloud_watch_logs_role_arn  = aws_iam_role.devsecops_factory_cloudtrail_role.arn
  enable_logging             = true
  enable_log_file_validation = true
  is_multi_region_trail      = true
}

resource "aws_cloudwatch_log_metric_filter" "devsecops_factory_pipeline_state_change_metric" {
  name           = "${var.devsecops_factory_name}-pipeline-state-change-metric"
  pattern        = <<EOF
    "{ ($.eventName = "StartPipelineExecution") || ($.eventName = "StopPipelineExecution") || ($.eventName = "UpdatePipeline") || ($.eventName = "DeletePipeline") }"
  EOF
  log_group_name = aws_cloudwatch_log_group.devsecops_factory_cloudtrail_log_group.name

  metric_transformation {
    name      = "pipelineEvent"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "devsecops_factory_pipeline_state_change_metric_alarm" {
  alarm_name          = "${var.devsecops_factory_name}-cloudtrail-pipeline-event-change"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "pipelineEvent"
  namespace           = "CloudTrailMetrics"
  period              = "1800"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Alarm when cloudtrail receives an state change event from codepipeline"
  alarm_actions       = ["${aws_sns_topic.devsecops_factory_cloudtrail_topic.arn}"]
}

resource "aws_cloudwatch_log_metric_filter" "devsecops_factory_codebuild_state_change_metric" {
  name           = "${var.devsecops_factory_name}-codebuild-state-change-metric"
  pattern        = <<EOF
    "{ (($.eventSource = "codebuild.amazonaws.com") && (($.eventName = "CreateProject") || ($.eventName = "DeleteProject"))) }"
  EOF
  log_group_name = aws_cloudwatch_log_group.devsecops_factory_cloudtrail_log_group.name

  metric_transformation {
    name      = "codebuildEvent"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "devsecops_factory_codebuild_state_change_metric_alarm" {
  alarm_name          = "${var.devsecops_factory_name}-cloudtrail-codebuild-event-change"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "codebuildEvent"
  namespace           = "CloudTrailMetrics"
  period              = "1800"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Alarm when cloudtrail receives an state change event from codebuild"
  alarm_actions       = ["${aws_sns_topic.devsecops_factory_cloudtrail_topic.arn}"]
}