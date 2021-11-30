resource "aws_codepipeline" "devsecops_factory_codepipeline" {
  name     = "${var.devsecops_factory_name}-pipeline"
  role_arn = aws_iam_role.devsecops_factory_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.devsecops_factory_artifacts_bucket.id
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.devsecops_factory_kms_key.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "test"
      }
    }
  }
}
