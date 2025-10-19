# VPC Module 🌐

This is a reusable Terraform module for creating production-grade AWS VPCs.

---

## 📦 What This Module Creates

- **1 VPC** (Virtual Private Cloud)
- **Public Subnets** (for internet-facing resources)
- **Private Subnets** (for internal resources)
- **Internet Gateway** (for public internet access)
- **NAT Gateways** (for private subnet internet access)
- **Route Tables** (for traffic routing)
- **VPC Flow Logs** (optional, for security)

---

## 🎯 Usage Example

```hcl
module "vpc" {
  source = "../../modules/vpc"

  # Project identification
  project_name = "mycompany"
  environment  = "prod"

  # VPC configuration
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # Subnets
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  # NAT Gateways
  enable_nat_gateway = true
  single_nat_gateway = false  # One NAT per AZ for high availability

  # Flow logs
  enable_flow_logs         = true
  flow_logs_retention_days = 30

  # Tags
  common_tags = {
    Team       = "Platform"
    CostCenter = "Engineering"
  }
}
```

---

## 📥 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_name` | Name of your project | `string` | - | ✅ |
| `environment` | Environment (prod/staging/dev) | `string` | - | ✅ |
| `vpc_cidr` | CIDR block for VPC | `string` | `"10.0.0.0/16"` | ❌ |
| `availability_zones` | List of AZs to use | `list(string)` | - | ✅ |
| `public_subnet_cidrs` | CIDRs for public subnets | `list(string)` | - | ✅ |
| `private_subnet_cidrs` | CIDRs for private subnets | `list(string)` | - | ✅ |
| `enable_nat_gateway` | Create NAT Gateway(s)? | `bool` | `true` | ❌ |
| `single_nat_gateway` | Use single NAT for all AZs? | `bool` | `false` | ❌ |
| `enable_flow_logs` | Enable VPC Flow Logs? | `bool` | `true` | ❌ |
| `flow_logs_retention_days` | Days to keep flow logs | `number` | `30` | ❌ |
| `enable_dns_hostnames` | Enable DNS hostnames? | `bool` | `true` | ❌ |
| `enable_dns_support` | Enable DNS support? | `bool` | `true` | ❌ |
| `common_tags` | Tags for all resources | `map(string)` | `{}` | ❌ |

---

## 📤 Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | The ID of the VPC |
| `vpc_cidr_block` | The CIDR block of the VPC |
| `vpc_arn` | The ARN of the VPC |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `nat_gateway_ids` | List of NAT Gateway IDs |
| `nat_gateway_public_ips` | List of NAT Gateway public IPs |
| `internet_gateway_id` | The ID of the Internet Gateway |
| `vpc_summary` | Summary of VPC configuration |
| `estimated_monthly_cost` | Estimated monthly cost |

---

## 💡 Examples

### Minimal Setup (1 AZ, 1 NAT)

```hcl
module "vpc" {
  source = "../../modules/vpc"

  project_name       = "testapp"
  environment        = "dev"
  vpc_cidr           = "10.0.0.0/20"
  availability_zones = ["us-east-1a"]

  public_subnet_cidrs  = ["10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24"]

  single_nat_gateway = true
  enable_flow_logs   = false
}

# Cost: ~$32/month
```

### Production Setup (3 AZs, 3 NATs)

```hcl
module "vpc" {
  source = "../../modules/vpc"

  project_name       = "webapp"
  environment        = "prod"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  single_nat_gateway = false
  enable_flow_logs   = true
}

# Cost: ~$110/month
```

---

## 🏗️ Architecture

```
                        ┌─────────────┐
                        │  Internet   │
                        └──────┬──────┘
                               │
                      ┌────────┴────────┐
                      │ Internet Gateway│
                      └────────┬────────┘
                               │
    ┌──────────────────────────┴──────────────────────────┐
    │               VPC (10.0.0.0/16)                      │
    │                                                      │
    │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ │
    │  │    AZ-A      │ │    AZ-B      │ │    AZ-C      │ │
    │  │              │ │              │ │              │ │
    │  │ ┌──────────┐ │ │ ┌──────────┐ │ │ ┌──────────┐ │ │
    │  │ │  Public  │ │ │ │  Public  │ │ │ │  Public  │ │ │
    │  │ │  Subnet  │ │ │ │  Subnet  │ │ │ │  Subnet  │ │ │
    │  │ │ .1.0/24  │ │ │ │ .2.0/24  │ │ │ │ .3.0/24  │ │ │
    │  │ │          │ │ │ │          │ │ │ │          │ │ │
    │  │ │ NAT GW   │ │ │ │ NAT GW   │ │ │ │ NAT GW   │ │ │
    │  │ └────┬─────┘ │ │ └────┬─────┘ │ │ └────┬─────┘ │ │
    │  │      │       │ │      │       │ │      │       │ │
    │  │ ┌────┴─────┐ │ │ ┌────┴─────┐ │ │ ┌────┴─────┐ │ │
    │  │ │ Private  │ │ │ │ Private  │ │ │ │ Private  │ │ │
    │  │ │  Subnet  │ │ │ │  Subnet  │ │ │ │  Subnet  │ │ │
    │  │ │ .11.0/24 │ │ │ │ .12.0/24 │ │ │ │ .13.0/24 │ │ │
    │  │ │ (App/DB) │ │ │ │ (App/DB) │ │ │ │ (App/DB) │ │ │
    │  │ └──────────┘ │ │ └──────────┘ │ │ └──────────┘ │ │
    │  └──────────────┘ └──────────────┘ └──────────────┘ │
    │                                                      │
    └──────────────────────────────────────────────────────┘
```

---

## 🔐 Security Features

- ✅ Private subnets have no direct internet access
- ✅ NAT Gateways for secure outbound connections
- ✅ Flow logs for traffic monitoring
- ✅ Encrypted flow logs
- ✅ Proper network segmentation

---

## 📊 Cost Breakdown

- **VPC**: Free
- **Subnets**: Free
- **Internet Gateway**: Free
- **NAT Gateway**: $0.045/hour = ~$32.40/month (per NAT)
- **NAT Data Processing**: $0.045/GB
- **Flow Logs**: $0.50/GB ingested
- **Elastic IPs**: Free when attached

**Total**: $32-110/month depending on configuration

---

## 🎓 Learn More

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-design.html)
- [NAT Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)

---

**Module Version**: 1.0.0  
**Terraform**: >= 1.0  
**AWS Provider**: ~> 5.0
