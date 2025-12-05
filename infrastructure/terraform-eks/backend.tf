# ============================================================================
# Terraform Backend Configuration - S3
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
  # Remote State Backend - S3 with Native State Locking
  # ============================================================================
  # Terraform 1.10+ supports native S3 state locking via use_lockfile
  # No DynamoDB table required!

  backend "s3" {
    bucket       = "fictions-api-terraform-state-development"
    key          = "eks/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # Enable native S3 state locking (Terraform 1.10+)
  }
}

