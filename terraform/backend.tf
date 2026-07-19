terraform {
  backend "s3" {
    bucket       = "sre-production-platform-tfstate-wiliender"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # Substitui o antigo dynamodb_table
  }
}