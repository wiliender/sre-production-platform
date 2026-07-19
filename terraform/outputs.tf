# ==============================================================================
# EXPOSIÇÃO DE OUTPUTS DA VPC (CONECTIVIDADE REDE -> CLUSTER)
# ==============================================================================
# Estes blocos coletam as informações estruturais geradas pelo módulo da VPC
# e as expõem globalmente. Sem isso, o módulo do EKS não saberia
# em qual rede e em quais subnets ele deve criar o cluster e os nós.

# Expõe o ID único da VPC criada na AWS
output "vpc_id" {
  description = "O ID da VPC principal para vincular o EKS e os Security Groups"
  value       = module.vpc.vpc_id # Captura o ID vindo de dentro do módulo vpc
}

# Expõe a lista de IDs das subnets privadas
output "private_subnets" {
  description = "Lista de IDs das subnets privadas onde os nós do EKS serão provisionados"
  value       = module.vpc.private_subnets # Captura a lista gerada pelo módulo vpc
}

# Expõe a lista de IDs das subnets públicas
output "public_subnets" {
  description = "Lista de IDs das subnets públicas onde os Load Balancers externos vão rodar"
  value       = module.vpc.public_subnets # Captura a lista gerada pelo módulo vpc
}

# ==============================================================================
# EXPOSIÇÃO DE OUTPUTS GLOBAIS (CONECTIVIDADE ENTRE MÓDULOS)
# ==============================================================================
# Estes blocos funcionam como a "API pública" da sua infraestrutura raiz.
# Eles expõem os valores gerados pelo módulo IAM para que o Terraform principal 
# possa entregá-los a outros módulos ou exibi-los no terminal após o apply.

# Expõe o ARN da Role do Control Plane do EKS
output "cluster_role_arn" {
  description = "ARN da IAM Role do cluster EKS passada para a raiz"
  value       = module.iam.cluster_role_arn # Busca o output que veio de dentro do módulo iam
}

# Expõe o ARN da Role dos Worker Nodes (as EC2s)
output "node_role_arn" {
  description = "ARN da IAM Role dos nós do EKS passada para a raiz"
  value       = module.iam.node_role_arn # Busca o output que veio de dentro do módulo iam
}