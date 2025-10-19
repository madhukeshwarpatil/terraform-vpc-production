#
# ╔═══════════════════════════════════════════════════════════════════╗
# ║                     VPC MODULE - VARIABLES                         ║
# ║                                                                     ║
# ║  This file defines all the inputs (variables) that this module    ║
# ║  needs to work. Think of these as settings you can customize.     ║
# ╚═══════════════════════════════════════════════════════════════════╝
#

# ============================================================================
# PROJECT IDENTIFICATION
# ============================================================================

variable "project_name" {
  description = "Name of your project (used in resource names)"
  type        = string

  # Example: "mycompany" or "webapp" or "ecommerce"
  # This will be used like: mycompany-prod-vpc
}

variable "environment" {
  description = "Environment name (prod, staging, dev)"
  type        = string

  # Example: "prod", "staging", "dev"
  # This helps you identify which environment a resource belongs to

  validation {
    condition     = contains(["prod", "staging", "dev"], var.environment)
    error_message = "Environment must be prod, staging, or dev."
  }
}

# ============================================================================
# VPC CONFIGURATION
# ============================================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC (IP address range for your network)"
  type        = string
  default     = "10.0.0.0/16"

  # CIDR explained:
  # 10.0.0.0/16 means:
  #   - Your network starts at 10.0.0.0
  #   - /16 means you have 65,536 IP addresses available
  #   - Range: 10.0.0.0 to 10.0.255.255
  #
  # Common sizes:
  #   /16 = 65,536 IPs (large, recommended for production)
  #   /20 = 4,096 IPs (medium, good for most cases)
  #   /24 = 256 IPs (small, for testing/dev)

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block (e.g., 10.0.0.0/16)."
  }
}

variable "enable_dns_hostnames" {
  description = "Should resources get DNS hostnames? (Recommended: true)"
  type        = bool
  default     = true

  # When true: ec2-1-2-3-4.compute.amazonaws.com
  # When false: Only IP addresses like 10.0.1.50
}

variable "enable_dns_support" {
  description = "Should DNS resolution work in VPC? (Recommended: true)"
  type        = bool
  default     = true

  # This allows resources to find each other by name
  # Example: database.internal can resolve to 10.0.11.50
}

# ============================================================================
# AVAILABILITY ZONES
# ============================================================================

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)

  # Availability Zones are like separate data centers in the same region
  # Using multiple AZs makes your infrastructure highly available
  #
  # Example: ["us-east-1a", "us-east-1b", "us-east-1c"]
  #
  # If one AZ has problems, your resources in other AZs keep working!
}

# ============================================================================
# SUBNET CONFIGURATION
# ============================================================================

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per availability zone)"
  type        = list(string)

  # Public subnets are for resources that need internet access
  # Examples: Load balancers, bastion hosts, NAT gateways
  #
  # Example for 3 AZs:
  # ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  #
  # Each /24 gives you 256 IP addresses

  validation {
    condition     = length(var.public_subnet_cidrs) > 0
    error_message = "You must provide at least one public subnet CIDR."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per availability zone)"
  type        = list(string)

  # Private subnets are for resources that should NOT be directly
  # accessible from the internet
  # Examples: Application servers, databases, cache servers
  #
  # Example for 3 AZs:
  # ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) > 0
    error_message = "You must provide at least one private subnet CIDR."
  }
}

# ============================================================================
# NAT GATEWAY CONFIGURATION
# ============================================================================

variable "enable_nat_gateway" {
  description = "Should we create NAT Gateway(s)? (Recommended: true for production)"
  type        = bool
  default     = true

  # NAT Gateway allows private resources to access the internet
  # (but internet cannot directly access them)
  #
  # Example uses:
  #   - Download software updates
  #   - Call external APIs
  #   - Send emails
  #
  # Cost: ~$32/month per NAT Gateway
}

variable "single_nat_gateway" {
  description = "Use only one NAT Gateway for all AZs? (false = one per AZ for high availability)"
  type        = bool
  default     = false

  # Single NAT Gateway (true):
  #   ✅ Cheaper (~$32/month)
  #   ❌ Single point of failure
  #   ❌ If one AZ fails, all private subnets lose internet
  #   👍 Good for: dev/staging environments
  #
  # One NAT per AZ (false):
  #   ✅ High availability
  #   ✅ If one AZ fails, others still have internet
  #   ❌ More expensive (~$32/month × number of AZs)
  #   👍 Good for: production environments
}

# ============================================================================
# VPC FLOW LOGS (For security and troubleshooting)
# ============================================================================

variable "enable_flow_logs" {
  description = "Should we record all network traffic? (Recommended: true for production)"
  type        = bool
  default     = true

  # Flow logs help you:
  #   - Investigate security incidents
  #   - Troubleshoot network issues
  #   - Monitor traffic patterns
  #   - Meet compliance requirements
  #
  # Cost: ~$0.50 per GB of logs
}

variable "flow_logs_retention_days" {
  description = "How many days to keep flow logs?"
  type        = number
  default     = 30

  # How long to keep the logs:
  #   7 days = good for dev/staging
  #   30 days = good for production
  #   90+ days = required for compliance

  validation {
    condition     = var.flow_logs_retention_days >= 1 && var.flow_logs_retention_days <= 365
    error_message = "Flow logs retention must be between 1 and 365 days."
  }
}

# ============================================================================
# TAGS (For organization and cost tracking)
# ============================================================================

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}

  # Tags help you:
  #   - Identify resources
  #   - Track costs by project/team
  #   - Automate operations
  #   - Meet compliance requirements
  #
  # Example:
  # {
  #   Environment = "production"
  #   Team        = "platform"
  #   CostCenter  = "engineering"
  #   ManagedBy   = "terraform"
  # }
}
