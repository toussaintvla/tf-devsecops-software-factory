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
      name             = "Source-Action"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]
      run_order        = 1

      configuration = {
        BranchName           = "${var.branch_name}"
        RepositoryName       = "${var.repository_name}"
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build-Secrets"

    action {
      name             = "Secret-Analysis"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["secret_artifacts"]
      run_order        = 2

      configuration = {
        ProjectName = "${aws_codebuild_project.devsecops_factory_secrets_analysis_codebuild_project.name}"
      }
    }
  }

  stage {
    name = "Build-SAST"

    action {
      name             = "SAST-Analysis"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["sast_artifacts"]
      run_order        = 3

      configuration = {
        ProjectName = "${aws_codebuild_project.devsecops_factory_sast_codebuild_project.name}"
      }
    }

    action {
      name             = "ECR-SAST-and-STG-Deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["ecr_sast_artifacts"]
      run_order        = 4

      configuration = {
        ProjectName = "${aws_codebuild_project.devsecops_factory_ecr_sast_codebuild_project.name}"
      }
    }
  }

  /* stage {
    name = "Build-Secrets-Scanning-and-SAST"

    action {
      name             = "Secret-Analysis"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["secret_artifacts"]
      run_order        = 2

      configuration = {
        ProjectName = "${aws_codebuild_project.devsecops_factory_secrets_analysis_codebuild_project.name}"
      }
    }

    action {
      name             = "SAST-Analysis"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["sast_artifacts"]
      run_order        = 2

      configuration = {
        ProjectName = "${aws_codebuild_project.devsecops_factory_sast_codebuild_project.name}"
      }
    }
  }

  stage {
    name = "Build-SAST-and-Deploy-STG"

    action {
      name             = "ECR-SAST-Analysis"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["ecr_sast_artifacts"]
      run_order        = 4

      configuration = {
        ProjectName = "${aws_codebuild_project.devsecops_factory_ecr_sast_codebuild_project.name}"
      }
    }
  } */

  stage {
    name = "Build-DAST"

    action {
      name             = "DAST-Analysis"
      category         = "Test"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["dast_artifacts"]
      run_order        = 5

      configuration = {
        ProjectName = "${aws_codebuild_project.devsecops_factory_dast_codebuild_project.name}"
      }
    }
  }

  stage {
    name = "Manual-Approval"

    action {
      name      = "Manual-Approval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 6

      configuration = {
        CustomData         = "There are no critical security vulnerabilities. Your approval is needed to deploy."
        ExternalEntityLink = "https://console.aws.amazon.com/codesuite/codepipeline/pipelines/${var.devsecops_factory_name}-pipeline/view?region=${var.region}"
        NotificationArn    = "${aws_sns_topic.devsecops_factory_approval_topic.arn}"
      }
    }
  }

  stage {
    name = "Deploy-PRD"

    action {
      name            = "EKS-Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]
      run_order       = 7

      configuration = {
        ProjectName = "${aws_codebuild_project.devsecops_factory_dast_codebuild_project.name}"
      }
    }
  }

  tags = {
    pipeline-name = var.devsecops_factory_name
  }
}
