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
  # Remote State Backend - S3
  # ============================================================================
  # For demo/development - basic S3 backend without state locking
  # State locking disabled for compatibility with Terraform < 1.10

  backend "s3" {
    bucket  = "fictions-api-terraform-state-development"
    key     = "eks/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

