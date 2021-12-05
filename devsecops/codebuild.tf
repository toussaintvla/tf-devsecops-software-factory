resource "aws_codebuild_project" "devsecops_factory_secrets_analysis_codebuild_project" {
  name           = "${var.devsecops_factory_name}-secrets-analysis-codebuild-project"
  description    = "Secrets Analysis Build Project"
  build_timeout  = "10"
  queued_timeout = "10"
  service_role   = aws_iam_role.devsecops_factory_sast_role.arn
  encryption_key = aws_kms_key.devsecops_factory_kms_key.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "CODECOMMIT_REPO_NAME"
      value = var.repository_name
    }

    environment_variable {
      name  = "REPOSITORY_URI"
      value = data.aws_ecr_repository.devsecops_factory_ecr_nonprod_repository.repository_url
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${path.module}/buildspec-gitsecrets.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name          = aws_cloudwatch_log_group.devsecops_factory_pipeline_log_group.name
      stream_name         = "${var.devsecops_factory_name}-secret-analysis-log-stream"
      /* report_build_status = "ENABLED" */
    }
  }

  tags = {
    pipeline-name = var.devsecops_factory_name
  }
}

resource "aws_codebuild_project" "devsecops_factory_sast_codebuild_project" {
  name           = "${var.devsecops_factory_name}-sast-codebuild-project"
  description    = "Static Code Analysis Build Project"
  build_timeout  = "10"
  queued_timeout = "10"
  service_role   = aws_iam_role.devsecops_factory_sast_role.arn
  encryption_key = aws_kms_key.devsecops_factory_kms_key.arn
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr_nonprod_repository
    }

    environment_variable {
      name  = "REPOSITORY_URI"
      value = data.aws_ecr_repository.devsecops_factory_ecr_nonprod_repository.repository_url
    }

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = var.eks_nonprod_cluster
    }

    environment_variable {
      name  = "EKS_KUBECTL_ROLE_ARN"
      value = aws_iam_role.devsecops_factory_sast_role.arn
    }

    environment_variable {
      name  = "SnykApiKey"
      value = aws_ssm_parameter.devsecops_factory_snyk_api_key.name
      type  = "PARAMETER_STORE"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${var.sast_tool[0]}" == "Anchore" ? "${path.module}/buildspec-anchore.yml" : "${path.module}/buildspec-snyk.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name          = aws_cloudwatch_log_group.devsecops_factory_pipeline_log_group.name
      stream_name         = "${var.devsecops_factory_name}-sast-analyisis-log-stream"
      /* report_build_status = "ENABLED" */
    }
  }

  tags = {
    pipeline-name = var.devsecops_factory_name
  }
}

resource "aws_codebuild_project" "devsecops_factory_ecr_sast_codebuild_project" {
  name           = "${var.devsecops_factory_name}-ecr-sast-codebuild-project"
  description    = "ECR Static Code Analysis Build Project"
  build_timeout  = "10"
  queued_timeout = "10"
  service_role   = aws_iam_role.devsecops_factory_sast_role.arn
  encryption_key = aws_kms_key.devsecops_factory_kms_key.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr_nonprod_repository
    }

    environment_variable {
      name  = "REPOSITORY_URI"
      value = data.aws_ecr_repository.devsecops_factory_ecr_nonprod_repository.repository_url
    }

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = var.eks_nonprod_cluster
    }

    environment_variable {
      name  = "EKS_KUBECTL_ROLE_ARN"
      value = aws_iam_role.devsecops_factory_sast_role.arn
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${path.module}/buildspec-ecr.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name          = aws_cloudwatch_log_group.devsecops_factory_pipeline_log_group.name
      stream_name         = "${var.devsecops_factory_name}-ecr-sast-analysis-log-stream"
      /* report_build_status = "ENABLED" */
    }
  }

  tags = {
    pipeline-name = var.devsecops_factory_name
  }
}

resource "aws_codebuild_project" "devsecops_factory_dast_codebuild_project" {
  name           = "${var.devsecops_factory_name}dast-analysis-codebuild-project"
  description    = "Dynamic Code Analysis Build Project"
  build_timeout  = "10"
  queued_timeout = "10"
  service_role   = aws_iam_role.devsecops_factory_sast_role.arn
  encryption_key = aws_kms_key.devsecops_factory_kms_key.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "OwaspZapApiKey"
      value = aws_ssm_parameter.devsecops_factory_owasp_zap_api_key.name
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "OwaspZapURL"
      value = aws_ssm_parameter.devsecops_factory_owasp_zap_url.name
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "ApplicationURL"
      value = aws_ssm_parameter.devsecops_factory_dast_app_url.name
      type  = "PARAMETER_STORE"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${path.module}/buildspec-owasp-zap.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name          = aws_cloudwatch_log_group.devsecops_factory_pipeline_log_group.name
      stream_name         = "${var.devsecops_factory_name}-dast-analysis-log-stream"
      /* report_build_status = "ENABLED" */
    }
  }

  tags = {
    pipeline-name = var.devsecops_factory_name
  }
}
