provider "aws" {
  region = "us-east-1"  # Adjust as needed
}

module "secure_baseline" {
  source      = "./modules/secure_baseline"
  vpc_cidr    = var.vpc_cidr
  environment = var.environment
}