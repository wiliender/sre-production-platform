output "cluster_name" {
  description = "Nome do cluster EKS"
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "ARN do cluster EKS"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint da API Kubernetes"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "Versão Kubernetes do cluster"
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "Security Group principal do cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_primary_security_group_id" {
  description = "Security Group principal criado pelo EKS"
  value       = module.eks.cluster_primary_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN do OIDC Provider utilizado pelo IRSA"
  value       = module.eks.oidc_provider_arn
}

output "cloudwatch_log_group_name" {
  description = "Nome do grupo de logs do Control Plane"
  value       = module.eks.cloudwatch_log_group_name
}