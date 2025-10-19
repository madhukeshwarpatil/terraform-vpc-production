#
# ╔═══════════════════════════════════════════════════════════════════╗
# ║                     VPC MODULE - MAIN CONFIGURATION                ║
# ║                                                                     ║
# ║  This file creates a production-grade AWS VPC with:               ║
# ║  • Public subnets (for internet-facing resources)                 ║
# ║  • Private subnets (for internal resources)                       ║
# ║  • NAT Gateways (for private subnet internet access)              ║
# ║  • Internet Gateway (for public internet access)                  ║
# ║  • Route tables (traffic routing rules)                           ║
# ║  • High availability across multiple availability zones           ║
# ╚═══════════════════════════════════════════════════════════════════╝
#

# ============================================================================
# VPC (Virtual Private Cloud)
# ============================================================================
# Think of VPC as your own private data center in the cloud
# It's an isolated network where all your resources live

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr # IP address range for your VPC (e.g., 10.0.0.0/16)

  # Enable DNS hostnames so resources get friendly names
  # Example: ec2-1-2-3-4.compute.amazonaws.com instead of just IP
  enable_dns_hostnames = var.enable_dns_hostnames

  # Enable DNS resolution so resources can find each other by name
  enable_dns_support = var.enable_dns_support

  # Tags help you identify and organize resources
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc"
    }
  )
}

# ============================================================================
# INTERNET GATEWAY
# ============================================================================
# This is like the front door to your VPC
# It allows resources in public subnets to access the internet

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-igw"
    }
  )
}

# ============================================================================
# PUBLIC SUBNETS
# ============================================================================
# Public subnets are like the front yard of your house
# Resources here can be accessed from the internet (like web servers)

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  # Auto-assign public IPs to resources in these subnets
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
      Type = "public"
      Tier = "public"
    }
  )
}

# ============================================================================
# PRIVATE SUBNETS
# ============================================================================
# Private subnets are like the backyard - protected and hidden
# Resources here cannot be directly accessed from the internet (like databases)

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  # Do NOT auto-assign public IPs (these are private!)
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
      Type = "private"
      Tier = "private"
    }
  )
}

# ============================================================================
# ELASTIC IPs FOR NAT GATEWAYS
# ============================================================================
# Elastic IPs are static public IP addresses
# NAT Gateways need these to allow private resources to reach the internet

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnet_cidrs)) : 0

  domain = "vpc" # This EIP is for VPC use

  # EIP must be created after the internet gateway exists
  depends_on = [aws_internet_gateway.main]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-eip-nat-${count.index + 1}"
    }
  )
}

# ============================================================================
# NAT GATEWAYS
# ============================================================================
# NAT Gateway = Network Address Translation Gateway
# It's like a one-way door: private resources can reach internet, but internet can't reach them
# Think of it as: Your phone can browse websites, but websites can't directly access your phone

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnet_cidrs)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-${count.index + 1}"
    }
  )

  # NAT Gateway must be created after IGW
  depends_on = [aws_internet_gateway.main]
}

# ============================================================================
# PUBLIC ROUTE TABLE
# ============================================================================
# Route tables are like GPS directions for network traffic
# This one tells traffic in public subnets how to reach the internet

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-rt"
      Type = "public"
    }
  )
}

# Add a route to the internet gateway
# This says: "For any traffic going to the internet (0.0.0.0/0), send it to the IGW"
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0" # 0.0.0.0/0 means "anywhere on the internet"
  gateway_id             = aws_internet_gateway.main.id
}

# Connect public subnets to the public route table
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ============================================================================
# PRIVATE ROUTE TABLES
# ============================================================================
# These route tables guide traffic for private subnets
# They use NAT Gateway to reach the internet (one-way access)

resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)) : 0

  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-private-rt-${count.index + 1}"
      Type = "private"
    }
  )
}

# Add routes to NAT Gateway for private subnets
# This says: "For internet traffic, use the NAT Gateway"
resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
}

# Connect private subnets to their route tables
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat_gateway ? (var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id) : aws_route_table.public.id
}

# ============================================================================
# VPC FLOW LOGS (Optional but recommended for production)
# ============================================================================
# Flow logs record all network traffic for security and troubleshooting
# It's like a security camera recording all traffic in and out

resource "aws_flow_log" "main" {
  count = var.enable_flow_logs ? 1 : 0

  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = "ALL" # Log ALL traffic (ACCEPT, REJECT, ALL)
  vpc_id          = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-flow-logs"
    }
  )
}

# CloudWatch Log Group to store flow logs
resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/${var.project_name}-${var.environment}-flow-logs"
  retention_in_days = var.flow_logs_retention_days

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-flow-logs"
    }
  )
}

# IAM role for flow logs to write to CloudWatch
resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${var.project_name}-${var.environment}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# IAM policy to allow flow logs to write to CloudWatch
resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${var.project_name}-${var.environment}-flow-logs-policy"
  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
