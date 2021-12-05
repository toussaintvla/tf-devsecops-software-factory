/* resource "aws_cloudtrail" "devsecops_factory_cloudtrail" {
  depends_on                 = [aws_s3_bucket_policy.devsecops_factory_cloudtrail_bucket_policy]
  name                       = "${var.devsecops_factory_name}-cloudtrail"
  s3_bucket_name             = aws_s3_bucket.devsecops_factory_artifacts_bucket.id
  cloud_watch_logs_group_arn = aws_cloudwatch_log_group.devsecops_factory_cloudtrail_log_group.arn
  cloud_watch_logs_role_arn  = aws_iam_role.devsecops_factory_cloudtrail_role.arn
  enable_logging             = true
  enable_log_file_validation = true
  is_multi_region_trail      = true
} */