resource "aws_lambda_function" "devsecops_factory_lambda" {
  filename      = "${path.module}/${var.devsecops_factory_code}"
  function_name = "${var.devsecops_factory_name}-function"
  role          = aws_iam_role.devsecops_factory_lambda_role.arn
  description   = "DevSecOps Software Factory Function - Import SecurityHub"
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("${path.module}/${var.devsecops_factory_code}")
  memory_size      = "3008"
  runtime          = "python3.8"
  timeout          = "600"

  tracing_config {
    mode = "Active"
  }

  tags = {
    pipeline-name = "${var.devsecops_factory_name}-pipeline"
  }
}