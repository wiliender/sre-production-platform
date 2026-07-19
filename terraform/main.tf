module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
}

module "iam" {

  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment

}

module "eks" {
  source = "./modules/eks"

  project_name       = var.project_name
  environment        = var.environment
  kubernetes_version = var.kubernetes_version

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  cluster_role_arn   = module.iam.cluster_role_arn

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [
    module.vpc,
    module.iam
  ]
}