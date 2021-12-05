data "aws_caller_identity" "current" {}

/* data "local_file" "buildspec_local" {
  filename = "${path.module}/build/buildspec.yml.tmpl"
} */

# "${data.local_file.buildspec_local.content}"