resource "aws_config_config_rule" "devsecops_factory_1_rule" {
  name        = "${var.devsecops_factory_name}-codebuild-project-envvar-awscred-check"
  description = <<EOF
    "Checks whether the project contains environment variables
    AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY. The rule is NON_COMPLIANT
    when the project environment variables contains plaintext credentials."
  EOF

  scope {
    compliance_resource_types = ["AWS::CodeBuild::Project"]
  }

  source {
    owner             = "AWS"
    source_identifier = "CODEBUILD_PROJECT_ENVVAR_AWSCRED_CHECK"
  }
}

resource "aws_config_config_rule" "devsecops_factory_2_rule" {
  name        = "${var.devsecops_factory_name}-codebuild-project-source-repo-url-check"
  description = <<EOF
    "Checks whether the source repository URL contains either personal
    access tokens or user name and password. The rule is
    complaint with the usage of OAuth to grant authorization for accessing repositories."
  EOF

  scope {
    compliance_resource_types = ["AWS::CodeBuild::Project"]
  }

  source {
    owner             = "AWS"
    source_identifier = "CODEBUILD_PROJECT_SOURCE_REPO_URL_CHECK"
  }
}

resource "aws_config_config_rule" "devsecops_factory_3_rule" {
  name        = "${var.devsecops_factory_name}-cloud-trail-log-file-validation-enabled"
  description = <<EOF
    "Checks whether AWS CloudTrail creates a signed digest file with logs.
    AWS recommends that the file validation must be enabled on all trails.
    The rule is noncompliant if the validation is not enabled."
  EOF

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_LOG_FILE_VALIDATION_ENABLED"
  }
}