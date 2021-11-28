module "devsecops_software_factory" {
  source = "../devsecops"

  region                 = var.region
  devsecops_factory_code = "../devsecops/${var.devsecops_factory_code}"
}