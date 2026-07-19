module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${var.project_name}-${var.environment}"
  kubernetes_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Utiliza o IAM Role que criamos.
  create_iam_role = false
  iam_role_arn    = var.cluster_role_arn

  # Modelo moderno de autenticação do EKS.
  authentication_mode = "API_AND_CONFIG_MAP"

  # Cria uma Access Entry para a identidade que executa o Terraform.
  enable_cluster_creator_admin_permissions = true

  # Endpoint público para acesso via kubectl durante o laboratório.
  endpoint_public_access = true

  # Mantém também o endpoint privado para comunicação interna.
  endpoint_private_access = true

  # Cria um OIDC Provider para futuros IAM Roles for Service Accounts.
  enable_irsa = true

  # Logs do Control Plane.
  enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  cloudwatch_log_group_retention_in_days = 7

  # Criptografia de Kubernetes Secrets utilizando uma chave KMS.
  encryption_config = {
    resources = ["secrets"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}"
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  )
}