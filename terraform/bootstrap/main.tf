# 1. Definição do Bucket S3 para salvar o State
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "sre-production-platform-tfstate-wiliender" # Tem que ser unico
  force_destroy = false
}

# 2. Configuração de Versionamento (para recuperar states antigos se der ruim)
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Configuração de Criptografia (Garante os dados protegidos em repouso)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. Bloqueio de Acesso Público (Garante que ninguém na internet veja seu state)
resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Tabela do DynamoDB para o State Locking (Evita concorrência de apply)
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}