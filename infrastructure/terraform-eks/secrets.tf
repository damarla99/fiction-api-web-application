# AWS Secrets Manager
resource "aws_secretsmanager_secret" "jwt_secret" {
  name        = "${var.project_name}/jwt-secret"
  description = "JWT secret for ${var.project_name} authentication"

  recovery_window_in_days = 7

  tags = {
    Name = "${var.project_name}-jwt-secret"
  }
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = var.jwt_secret != "" ? var.jwt_secret : "change-this-in-production-${random_password.jwt_secret.result}"
}

resource "aws_secretsmanager_secret" "mongodb_uri" {
  name        = "${var.project_name}/mongodb-uri"
  description = "MongoDB connection URI for ${var.project_name}"

  recovery_window_in_days = 7

  tags = {
    Name = "${var.project_name}-mongodb-uri"
  }
}

resource "aws_secretsmanager_secret_version" "mongodb_uri" {
  secret_id     = aws_secretsmanager_secret.mongodb_uri.id
  secret_string = var.mongodb_uri != "" ? var.mongodb_uri : "mongodb://mongodb-service:27017/fictions_db"
}

resource "random_password" "jwt_secret" {
  length  = 32
  special = true
}

# Kubernetes Secrets (synced from AWS Secrets Manager)
resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "fictions-api-secrets"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    JWT_SECRET  = var.jwt_secret != "" ? var.jwt_secret : random_password.jwt_secret.result
    MONGODB_URI = var.mongodb_uri != "" ? var.mongodb_uri : "mongodb://mongodb-service:27017/fictions_db"
  }

  type = "Opaque"

  depends_on = [module.eks]
}

