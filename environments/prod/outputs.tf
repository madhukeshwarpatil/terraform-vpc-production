#
# ╔═══════════════════════════════════════════════════════════════════╗
# ║          PRODUCTION ENVIRONMENT - OUTPUTS                          ║
# ║                                                                     ║
# ║  This file displays important information after                   ║
# ║  terraform apply completes.                                       ║
# ╚═══════════════════════════════════════════════════════════════════╝
#

# ============================================================================
# VPC INFORMATION
# ============================================================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

# ============================================================================
# SUBNET INFORMATION
# ============================================================================

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = module.vpc.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = module.vpc.private_subnet_cidrs
}

# ============================================================================
# NAT GATEWAY INFORMATION
# ============================================================================

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "nat_gateway_ips" {
  description = "List of Elastic IPs attached to NAT Gateways"
  value       = module.vpc.nat_gateway_public_ips
}

# ============================================================================
# FLOW LOGS INFORMATION
# ============================================================================

output "flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = module.vpc.flow_log_id
}

output "flow_log_cloudwatch_log_group" {
  description = "CloudWatch Log Group for VPC Flow Logs"
  value       = module.vpc.flow_log_cloudwatch_log_group
}

# ============================================================================
# SUMMARY
# ============================================================================

output "vpc_summary" {
  description = "Summary of VPC configuration"
  value       = module.vpc.vpc_summary
}

output "estimated_monthly_cost" {
  description = "Estimated monthly cost in USD"
  value       = module.vpc.estimated_monthly_cost
}

# ============================================================================
# HOW TO USE THESE OUTPUTS
# ============================================================================
#
# After running "terraform apply", you'll see these values displayed.
#
# You can also query them anytime:
#   terraform output vpc_id
#   terraform output -json  # Get all outputs in JSON format
#
# Use these outputs when creating additional resources:
#
# Example: Create EC2 instance in a private subnet
#   subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]
#
# Example: Create security group in the VPC
#   vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
#
# ============================================================================
