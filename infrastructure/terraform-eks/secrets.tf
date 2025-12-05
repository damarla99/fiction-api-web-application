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
  secret_string = var.jwt_secret
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
  secret_string = var.mongodb_uri
}

# Note: Kubernetes secrets are managed via kubectl manifests in kubernetes/secrets.yaml
# This allows for easier updates without Terraform apply

