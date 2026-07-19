variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente da infraestrutura"
  type        = string
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes utilizada pelo cluster EKS"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o cluster EKS será criado"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas utilizadas pelo EKS"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "ARN do IAM Role utilizado pelo Control Plane do EKS"
  type        = string
}

variable "tags" {
  description = "Tags comuns aplicadas aos recursos"
  type        = map(string)
  default     = {}
}