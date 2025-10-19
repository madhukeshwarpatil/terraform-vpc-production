#
# ╔═══════════════════════════════════════════════════════════════════╗
# ║                     VPC MODULE - OUTPUTS                           ║
# ║                                                                     ║
# ║  This file defines what information this module gives back         ║
# ║  to whoever uses it. These are like return values.                ║
# ╚═══════════════════════════════════════════════════════════════════╝
#

# ============================================================================
# VPC OUTPUTS
# ============================================================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id

  # Example: vpc-0abc123def456789
  # You'll need this ID to create resources inside this VPC
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block

  # Example: 10.0.0.0/16
  # Useful for security group rules and network planning
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.main.arn

  # ARN = Amazon Resource Name (unique identifier across all of AWS)
  # Example: arn:aws:ec2:us-east-1:123456789012:vpc/vpc-0abc123
}

# ============================================================================
# INTERNET GATEWAY OUTPUTS
# ============================================================================

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id

  # Example: igw-0abc123def456789
  # The gateway that connects your VPC to the internet
}

# ============================================================================
# PUBLIC SUBNET OUTPUTS
# ============================================================================

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id

  # Example: ["subnet-abc123", "subnet-def456", "subnet-ghi789"]
  # Use these IDs when creating resources in public subnets
  # Like: Load balancers, bastion hosts, NAT gateways
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block

  # Example: ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  # The IP address ranges for your public subnets
}

output "public_subnet_availability_zones" {
  description = "List of availability zones for public subnets"
  value       = aws_subnet.public[*].availability_zone

  # Example: ["us-east-1a", "us-east-1b", "us-east-1c"]
  # Shows which AZ each subnet is in
}

# ============================================================================
# PRIVATE SUBNET OUTPUTS
# ============================================================================

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id

  # Example: ["subnet-111aaa", "subnet-222bbb", "subnet-333ccc"]
  # Use these IDs when creating resources in private subnets
  # Like: Application servers, databases, cache servers
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block

  # Example: ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  # The IP address ranges for your private subnets
}

output "private_subnet_availability_zones" {
  description = "List of availability zones for private subnets"
  value       = aws_subnet.private[*].availability_zone

  # Example: ["us-east-1a", "us-east-1b", "us-east-1c"]
  # Shows which AZ each subnet is in
}

# ============================================================================
# NAT GATEWAY OUTPUTS
# ============================================================================

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id

  # Example: ["nat-0abc123", "nat-0def456"]
  # The gateways that allow private resources to reach the internet
}

output "nat_gateway_public_ips" {
  description = "List of public IPs assigned to NAT Gateways"
  value       = aws_eip.nat[*].public_ip

  # Example: ["54.123.45.67", "54.234.56.78"]
  # These are the IP addresses that external services will see
  # when your private resources make outbound connections
}

# ============================================================================
# ROUTE TABLE OUTPUTS
# ============================================================================

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id

  # Example: rtb-0abc123def456789
  # The routing rules for public subnets
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.private[*].id

  # Example: ["rtb-111aaa", "rtb-222bbb"]
  # The routing rules for private subnets
}

# ============================================================================
# FLOW LOGS OUTPUTS
# ============================================================================

output "flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = var.enable_flow_logs ? aws_flow_log.main[0].id : null

  # Example: fl-0abc123def456789
  # null if flow logs are disabled
}

output "flow_log_cloudwatch_log_group" {
  description = "Name of the CloudWatch Log Group for VPC Flow Logs"
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.flow_logs[0].name : null

  # Example: /aws/vpc/myproject-prod-flow-logs
  # Where your flow logs are stored
  # null if flow logs are disabled
}

# ============================================================================
# SUMMARY OUTPUTS (Useful for documentation/dashboards)
# ============================================================================

output "vpc_summary" {
  description = "A summary of the VPC configuration"
  value = {
    vpc_id             = aws_vpc.main.id
    vpc_cidr           = aws_vpc.main.cidr_block
    environment        = var.environment
    project_name       = var.project_name
    availability_zones = var.availability_zones
    public_subnets     = length(var.public_subnet_cidrs)
    private_subnets    = length(var.private_subnet_cidrs)
    nat_gateways       = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnet_cidrs)) : 0
    flow_logs_enabled  = var.enable_flow_logs
  }

  # This creates a nice summary object with all key information
  # Useful for displaying in dashboards or documentation
  #
  # Example output:
  # {
  #   vpc_id = "vpc-0abc123"
  #   vpc_cidr = "10.0.0.0/16"
  #   environment = "prod"
  #   project_name = "mycompany"
  #   availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  #   public_subnets = 3
  #   private_subnets = 3
  #   nat_gateways = 3
  #   flow_logs_enabled = true
  # }
}

# ============================================================================
# COST ESTIMATE OUTPUT (Helpful for budgeting)
# ============================================================================

output "estimated_monthly_cost" {
  description = "Estimated monthly cost in USD (approximate)"
  value = {
    nat_gateways = var.enable_nat_gateway ? (var.single_nat_gateway ? 32.40 : (length(var.public_subnet_cidrs) * 32.40)) : 0
    flow_logs    = var.enable_flow_logs ? 10.00 : 0 # Approximate, depends on traffic
    total        = (var.enable_nat_gateway ? (var.single_nat_gateway ? 32.40 : (length(var.public_subnet_cidrs) * 32.40)) : 0) + (var.enable_flow_logs ? 10.00 : 0)
    currency     = "USD"
    note         = "This is an estimate. Actual costs may vary based on data transfer and usage."
  }

  # Example output:
  # {
  #   nat_gateways = 97.20  # 3 NAT gateways × $32.40
  #   flow_logs = 10.00
  #   total = 107.20
  #   currency = "USD"
  #   note = "This is an estimate..."
  # }
  #
  # Pricing notes:
  #   - NAT Gateway: $0.045/hour = ~$32.40/month (per NAT)
  #   - NAT Data Processing: $0.045/GB
  #   - Flow Logs: $0.50/GB ingested
  #   - VPC itself: FREE!
}
