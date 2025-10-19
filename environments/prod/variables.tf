#
# ╔═══════════════════════════════════════════════════════════════════╗
# ║          PRODUCTION ENVIRONMENT - VARIABLE DEFINITIONS             ║
# ║                                                                     ║
# ║  This file defines all the settings you can customize.            ║
# ║  Actual values go in terraform.tfvars file.                       ║
# ╚═══════════════════════════════════════════════════════════════════╝
#

# ============================================================================
# AWS CONFIGURATION
# ============================================================================

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"

  # Popular regions:
  #   us-east-1      = US East (Virginia) - Cheapest, most services
  #   us-west-2      = US West (Oregon) - Good for West Coast
  #   eu-west-1      = Europe (Ireland) - Good for Europe
  #   ap-southeast-1 = Asia Pacific (Singapore) - Good for Asia
  #
  # Choose a region close to your users for better performance!
}

# ============================================================================
# PROJECT IDENTIFICATION
# ============================================================================

variable "project_name" {
  description = "Name of your project (used in all resource names)"
  type        = string

  # Examples: "mycompany", "ecommerce", "blog", "api"
  # Keep it short and lowercase, no spaces or special characters
  # This will be used like: mycompany-prod-vpc
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"

  # For this production environment, this is set to "prod"
  # If you copy this for other environments, change to "staging" or "dev"
}

variable "repository_url" {
  description = "URL of your code repository (optional)"
  type        = string
  default     = ""

  # Example: "https://github.com/yourcompany/infrastructure"
  # Helps you track which code created which resources
  # Optional - leave empty if you don't want to specify
}

# ============================================================================
# VPC CONFIGURATION
# ============================================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  # 10.0.0.0/16 gives you 65,536 IP addresses
  # Range: 10.0.0.0 to 10.0.255.255
  #
  # Production recommendation: /16 (large)
  #
  # IMPORTANT: Make sure this doesn't overlap with:
  #   - Other VPCs you have
  #   - Your office network (if using VPN)
  #   - Other cloud providers (if using multi-cloud)
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true

  # Keep this true - it makes life easier
  # Resources will get names like: ec2-1-2-3-4.compute.amazonaws.com
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true

  # Keep this true - required for resources to find each other by name
}

# ============================================================================
# AVAILABILITY ZONES
# ============================================================================

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 3

  # Production recommendation: 3 availability zones
  # Staging: 2 availability zones
  # Dev: 1 availability zone (to save money)
  #
  # More AZs = more highly available, but more expensive
  # (more NAT Gateways, more data transfer costs)
}

# ============================================================================
# SUBNET CONFIGURATION
# ============================================================================

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  # Each /24 gives you 256 IP addresses (actually 251 usable)
  #
  # Public subnets are for:
  #   - Load balancers
  #   - NAT Gateways
  #   - Bastion hosts
  #
  # Rule: Number of CIDRs must match az_count!
  # If az_count = 2, you need 2 CIDRs
  # If az_count = 3, you need 3 CIDRs
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  # Each /24 gives you 256 IP addresses (actually 251 usable)
  #
  # Private subnets are for:
  #   - Application servers
  #   - Databases
  #   - Cache servers
  #   - Internal services
  #
  # Rule: Number of CIDRs must match az_count!
  #
  # Tip: Use a different range than public (e.g., 10.0.11.x instead of 10.0.1.x)
  # This makes it obvious which subnet is which
}

# ============================================================================
# NAT GATEWAY CONFIGURATION
# ============================================================================

variable "enable_nat_gateway" {
  description = "Create NAT Gateway(s) for private subnets"
  type        = bool
  default     = true

  # Production: true (required!)
  # Dev/Testing: can be false to save money
  #
  # Without NAT Gateway, private subnets can't reach internet
  # (no software updates, no external API calls, etc.)
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all availability zones"
  type        = bool
  default     = false

  # Production: false (high availability)
  #   - Creates one NAT per AZ
  #   - Cost: ~$32/month per AZ
  #   - If one AZ fails, others still work
  #
  # Staging/Dev: true (cost savings)
  #   - Creates only one NAT
  #   - Cost: ~$32/month total
  #   - If that AZ fails, all private subnets lose internet
}

# ============================================================================
# VPC FLOW LOGS CONFIGURATION
# ============================================================================

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for network traffic logging"
  type        = bool
  default     = true

  # Production: true (security requirement!)
  # Flow logs help you:
  #   - Investigate security incidents
  #   - Troubleshoot connectivity issues
  #   - Meet compliance requirements
  #
  # Cost: ~$0.50 per GB of logs
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 30

  # Production: 30-90 days
  # Staging: 7-14 days
  # Dev: 7 days
  #
  # Longer retention = higher cost
  # Check your compliance requirements!
}

# ============================================================================
# TAGS
# ============================================================================

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}

  # You can add tags in terraform.tfvars:
  #
  # common_tags = {
  #   Team       = "platform"
  #   CostCenter = "engineering"
  #   Owner      = "john.doe@company.com"
  #   Backup     = "true"
  # }
  #
  # Tags are super useful for:
  #   - Cost tracking (see spending by team/project)
  #   - Resource organization (filter in AWS console)
  #   - Automation (scripts can find resources by tag)
  #   - Compliance (auditing requirements)
}

# ============================================================================
# CUSTOMIZATION TIPS
# ============================================================================
#
# To customize for YOUR needs:
#
# 1. Copy this file structure
# 2. Edit values in terraform.tfvars (not here!)
# 3. Run terraform plan to see what will be created
# 4. Run terraform apply to create it
#
# Common customizations:
#
# SMALLER NETWORK (for testing):
#   vpc_cidr = "10.0.0.0/20"
#   az_count = 1
#   single_nat_gateway = true
#
# LARGER NETWORK (for big production):
#   vpc_cidr = "10.0.0.0/14"
#   az_count = 3
#   single_nat_gateway = false
#
# SAVE MONEY (development):
#   enable_nat_gateway = false
#   enable_flow_logs = false
#   az_count = 1
#
# ============================================================================
