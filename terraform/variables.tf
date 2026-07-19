variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "kubernetes_version" {
  description = "Versão Kubernetes utilizada pelo cluster EKS"
  type        = string
  default     = "1.35"
}