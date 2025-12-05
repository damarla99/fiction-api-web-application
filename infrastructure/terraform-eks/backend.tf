# ============================================================================
# Terraform Backend Configuration - S3 + DynamoDB
# ============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  # ============================================================================
  # Remote State Backend - S3 with DynamoDB Locking
  # ============================================================================
  # Uncomment after creating S3 bucket and DynamoDB table manually

  backend "s3" {
    bucket         = "fictions-api-terraform-state-development"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "fictions-api-terraform-locks-development"
    encrypt        = true
  }
}

