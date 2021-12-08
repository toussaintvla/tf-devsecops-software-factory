data "aws_ecr_repository" "devsecops_factory_ecr_nonprod_repository" {
  name = var.ecr_nonprod_repository
}

data "aws_ecr_repository" "devsecops_factory_ecr_prod_repository" {
  name = var.ecr_prod_repository
}