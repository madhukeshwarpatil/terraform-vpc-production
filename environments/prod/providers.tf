#
# ╔═══════════════════════════════════════════════════════════════════╗
# ║                  TERRAFORM & AWS PROVIDER CONFIGURATION            ║
# ║                                                                     ║
# ║  This file tells Terraform:                                       ║
# ║  1. Which version of Terraform to use                             ║
# ║  2. Which version of AWS provider to use                          ║
# ║  3. How to connect to AWS                                         ║
# ╚═══════════════════════════════════════════════════════════════════╝
#

# ============================================================================
# TERRAFORM VERSION REQUIREMENTS
# ============================================================================

terraform {
  # Terraform version - we need at least version 1.0
  # This ensures we have all the modern features
  required_version = ">= 1.0"

  # Provider requirements
  # Providers are plugins that let Terraform talk to cloud services like AWS
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Official AWS provider from HashiCorp
      version = "~> 5.0"        # Use version 5.x (but not 6.0 when it comes out)
    }
  }
}

# ============================================================================
# AWS PROVIDER CONFIGURATION
# ============================================================================

provider "aws" {
  # AWS Region - where your resources will be created
  # Examples: us-east-1 (Virginia), us-west-2 (Oregon), eu-west-1 (Ireland)
  region = var.aws_region

  # Default tags - these will be added to EVERY resource you create
  # Super useful for:
  #   - Cost tracking (see costs by environment/project)
  #   - Organization (filter resources in AWS console)
  #   - Automation (scripts can find resources by tags)
  #   - Compliance (meet auditing requirements)
  default_tags {
    tags = {
      Environment = var.environment    # prod, staging, or dev
      Project     = var.project_name   # Your project name
      ManagedBy   = "Terraform"        # Helps you know what's managed by Terraform
      CreatedBy   = "Terraform"        # Same as above
      Repository  = var.repository_url # Link to your code repository (optional)
    }
  }

  # How Terraform connects to AWS:
  # ================================
  # Option 1: AWS CLI credentials (EASIEST)
  #   - Run: aws configure
  #   - Terraform will automatically use those credentials
  #   - Recommended for: local development
  #
  # Option 2: Environment variables
  #   export AWS_ACCESS_KEY_ID="your-key"
  #   export AWS_SECRET_ACCESS_KEY="your-secret"
  #   export AWS_REGION="us-east-1"
  #   - Recommended for: CI/CD pipelines
  #
  # Option 3: IAM Role (most secure)
  #   - Use when running Terraform from an EC2 instance
  #   - Or when using AWS CodeBuild/CodePipeline
  #   - Recommended for: production deployments
  #
  # You don't need to specify credentials here - they're loaded automatically!
}
