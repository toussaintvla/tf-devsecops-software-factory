data "aws_caller_identity" "current" {}

data "local_file" "buildspec_gitsecrets" {
  filename = "${path.module}/build/buildspec-gitsecrets.yml"
}

data "local_file" "buildspec_anchore" {
  filename = "${path.module}/build/buildspec-anchore.yml"
}

data "local_file" "buildspec_ecr" {
  filename = "${path.module}/build/buildspec-ecr.yml"
}

data "local_file" "buildspec_owasp_zap" {
  filename = "${path.module}/build/buildspec-owasp-zap.yml"
}

data "local_file" "buildspec_snyk" {
  filename = "${path.module}/build/buildspec-snyk.yml"
}

data "local_file" "buildspec_prod" {
  filename = "${path.module}/build/buildspec-prod.yml"
}