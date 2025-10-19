#
# ╔═══════════════════════════════════════════════════════════════════╗
# ║          PRODUCTION ENVIRONMENT - ACTUAL VALUES                    ║
# ║                                                                     ║
# ║  📝 THIS IS WHERE YOU PUT YOUR REAL VALUES!                       ║
# ║                                                                     ║
# ║  This file contains the actual configuration for your             ║
# ║  production environment. Customize these values for your needs.   ║
# ╚═══════════════════════════════════════════════════════════════════╝
#

# ============================================================================
# 🌍 AWS REGION
# ============================================================================

# Which AWS region to create resources in
# Choose a region close to your users for better performance
aws_region = "us-east-1"

# Other options:
# aws_region = "us-west-2"      # Oregon
# aws_region = "eu-west-1"      # Ireland
# aws_region = "ap-southeast-1" # Singapore

# ============================================================================
# 📛 PROJECT INFORMATION
# ============================================================================

# Your project name - used in all resource names
# ⚠️ CHANGE THIS to match your project!
project_name = "mycompany"

# Environment name (this is production)
environment = "prod"

# Optional: Link to your code repository
repository_url = "https://github.com/yourcompany/infrastructure"

# ============================================================================
# 🌐 VPC CONFIGURATION
# ============================================================================

# IP address range for your VPC
# 10.0.0.0/16 = 65,536 IP addresses
vpc_cidr = "10.0.0.0/16"

# Enable DNS features (recommended: keep these true)
enable_dns_hostnames = true
enable_dns_support   = true

# ============================================================================
# 🏢 AVAILABILITY ZONES
# ============================================================================

# Number of availability zones to use
# Production recommendation: 3 for high availability
az_count = 3

# ============================================================================
# 🔀 SUBNET CONFIGURATION
# ============================================================================

# Public subnets - for internet-facing resources
# Each /24 = 256 IPs (251 usable)
public_subnet_cidrs = [
  "10.0.1.0/24", # AZ 1
  "10.0.2.0/24", # AZ 2
  "10.0.3.0/24"  # AZ 3
]

# Private subnets - for internal resources
# Each /24 = 256 IPs (251 usable)
private_subnet_cidrs = [
  "10.0.11.0/24", # AZ 1
  "10.0.12.0/24", # AZ 2
  "10.0.13.0/24"  # AZ 3
]

# ============================================================================
# 🚪 NAT GATEWAY CONFIGURATION
# ============================================================================

# Create NAT Gateways? (Required for private subnets to access internet)
enable_nat_gateway = true

# Use single NAT Gateway? 
# false = one per AZ (high availability, ~$97/month)
# true  = only one (cheaper at ~$32/month, but single point of failure)
single_nat_gateway = false

# ============================================================================
# 📊 VPC FLOW LOGS
# ============================================================================

# Enable network traffic logging? (Recommended for security)
enable_flow_logs = true

# How long to keep logs (days)
flow_logs_retention_days = 30

# ============================================================================
# 🏷️  RESOURCE TAGS
# ============================================================================

# Tags for all resources (helps with organization and cost tracking)
common_tags = {
  Team       = "Platform"
  CostCenter = "Engineering"
  Owner      = "platform-team@mycompany.com"
  Compliance = "SOC2"
  Backup     = "required"
}

# ============================================================================
# 💰 ESTIMATED MONTHLY COST (based on above configuration)
# ============================================================================
#
# NAT Gateways: 3 × $32.40 = $97.20/month
#   + Data processing: ~$0.045/GB
#
# VPC Flow Logs: ~$10-50/month (depends on traffic)
#   + Storage: $0.50/GB ingested
#
# VPC itself: FREE
#
# TOTAL: ~$110-150/month (varies with usage)
#
# 💡 To reduce costs:
#   - Set single_nat_gateway = true (saves ~$65/month)
#   - Set enable_flow_logs = false (saves ~$10-50/month)
#   - Reduce az_count to 2 (saves ~$32/month)
#
# ============================================================================
# 🎯 CUSTOMIZATION EXAMPLES
# ============================================================================
#
# Example 1: Smaller network for testing
# -------------------------------------
# vpc_cidr = "10.0.0.0/20"
# az_count = 2
# public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
# private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
# single_nat_gateway = true
#
# Example 2: Larger network for enterprise
# ---------------------------------------
# vpc_cidr = "10.0.0.0/14"
# public_subnet_cidrs  = ["10.0.1.0/22", "10.0.5.0/22", "10.0.9.0/22"]
# private_subnet_cidrs = ["10.1.0.0/22", "10.1.4.0/22", "10.1.8.0/22"]
#
# Example 3: Cost-optimized for development
# ---------------------------------------
# az_count = 1
# public_subnet_cidrs  = ["10.0.1.0/24"]
# private_subnet_cidrs = ["10.0.11.0/24"]
# enable_nat_gateway = false
# enable_flow_logs = false
#
# ============================================================================
# ⚠️  IMPORTANT NOTES
# ============================================================================
#
# 1. DO NOT commit secrets to version control!
#    - This file is safe (no secrets)
#    - But be careful with actual credentials
#    - Add terraform.tfstate to .gitignore
#
# 2. VPC CIDR cannot be changed after creation
#    - Choose carefully!
#    - Make sure it doesn't overlap with other networks
#
# 3. Number of subnet CIDRs must match az_count
#    - 3 AZs = need 3 public + 3 private subnet CIDRs
#
# 4. Subnet CIDRs must be within VPC CIDR
#    - If VPC is 10.0.0.0/16, subnets must be 10.0.x.x
#
# 5. Test changes in a dev environment first!
#    - Use terraform plan to preview
#    - Create a dev copy to test big changes
#
# ============================================================================
