terraform {
  backend "s3" {
    encrypt        = "true"
    bucket         = "vladimir-toussaint"
    key            = "tf-devsecops-factory/tf-devsecops-factory.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-dynamodb"
  }
}