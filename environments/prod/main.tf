#
# ╔═══════════════════════════════════════════════════════════════════╗
# ║               PRODUCTION ENVIRONMENT - MAIN CONFIGURATION          ║
# ║                                                                     ║
# ║  This file uses the VPC module to create production network       ║
# ║  infrastructure. It's like a recipe that uses ingredients         ║
# ║  (the module) to bake a cake (your infrastructure).               ║
# ╚═══════════════════════════════════════════════════════════════════╝
#

# ============================================================================
# GET AVAILABLE AVAILABILITY ZONES
# ============================================================================
# This automatically finds all available AZs in your chosen region
# So you don't have to hardcode them!

data "aws_availability_zones" "available" {
  state = "available" # Only get AZs that are currently working

  # Some regions have special AZs that don't support all resource types
  # This filter excludes those
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# ============================================================================
# CREATE VPC USING THE VPC MODULE
# ============================================================================

module "vpc" {
  # Where to find the VPC module code
  # "../../modules/vpc" means: go up 2 folders, then into modules/vpc
  source = "../../modules/vpc"

  # Project identification
  project_name = var.project_name
  environment  = var.environment

  # VPC configuration
  vpc_cidr             = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  # Availability zones - use the first 3 available AZs
  # slice function: slice(list, start_index, end_index)
  # Example: If AZs are [a, b, c, d, e], slice gives us [a, b, c]
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Subnet configuration
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  # NAT Gateway configuration
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  # Flow logs configuration
  enable_flow_logs         = var.enable_flow_logs
  flow_logs_retention_days = var.flow_logs_retention_days

  # Tags that will be applied to all resources
  common_tags = var.common_tags
}

# ============================================================================
# WHAT HAPPENS WHEN YOU RUN "terraform apply"?
# ============================================================================
#
# 1. Terraform reads this file and the variables
# 2. It calls the VPC module with your settings
# 3. The module creates all the resources:
#    ✅ 1 VPC
#    ✅ 3 Public Subnets (one per AZ)
#    ✅ 3 Private Subnets (one per AZ)
#    ✅ 1 Internet Gateway
#    ✅ 3 NAT Gateways (or 1 if single_nat_gateway = true)
#    ✅ 3 Elastic IPs (for NAT Gateways)
#    ✅ Route Tables (for routing traffic)
#    ✅ VPC Flow Logs (if enabled)
#
# 4. After creation, outputs are displayed showing:
#    - VPC ID
#    - Subnet IDs
#    - NAT Gateway IDs
#    - Cost estimate
#
# ============================================================================
# EXAMPLE: ADDING MORE RESOURCES
# ============================================================================
#
# Once your VPC is created, you can add more resources to it:
#
# # Example: Create a security group
# resource "aws_security_group" "example" {
#   name        = "${var.project_name}-${var.environment}-sg"
#   description = "Example security group"
#   vpc_id      = module.vpc.vpc_id  # ← Use the VPC we just created!
#
#   # Allow HTTPS from anywhere
#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   # Allow all outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
#
# # Example: Create an EC2 instance in a private subnet
# resource "aws_instance" "app_server" {
#   ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
#   instance_type = "t3.micro"
#   
#   # Put it in the first private subnet
#   subnet_id = module.vpc.private_subnet_ids[0]
#   
#   tags = {
#     Name = "${var.project_name}-${var.environment}-app-server"
#   }
# }
#
# ============================================================================
