#
# ╔═══════════════════════════════════════════════════════════════════╗
# ║          TERRAFORM BACKEND CONFIGURATION (Remote State)            ║
# ║                                                                     ║
# ║  This file tells Terraform where to store its state file.        ║
# ║  The state file tracks what resources have been created.          ║
# ╚═══════════════════════════════════════════════════════════════════╝
#

# ============================================================================
# WHAT IS TERRAFORM STATE?
# ============================================================================
#
# Terraform keeps track of your infrastructure in a "state file".
# This file contains:
#   - What resources exist
#   - Their current configuration
#   - Relationships between resources
#
# State file is CRITICAL - losing it means Terraform forgets what it created!
#
# ============================================================================

# ============================================================================
# BACKEND OPTIONS
# ============================================================================
#
# Option 1: LOCAL BACKEND (Default - NOT RECOMMENDED FOR PRODUCTION)
# -------------------------------------------------------------------
# State file stored on your computer as "terraform.tfstate"
#
# Pros:
#   ✅ Simple, no setup needed
#   ✅ Free
#
# Cons:
#   ❌ Not shared with team
#   ❌ No locking (multiple people can't work together)
#   ❌ Can be lost if computer dies
#   ❌ Not secure (anyone with access to file can see secrets)
#
# Good for: Personal projects, learning, testing
#
# -------------------------------------------------------------------
#
# Option 2: S3 BACKEND (RECOMMENDED FOR PRODUCTION)
# -------------------------------------------------------------------
# State file stored in AWS S3 bucket
# Uses DynamoDB for locking (prevents conflicts)
#
# Pros:
#   ✅ Shared with team
#   ✅ Locking prevents conflicts
#   ✅ Versioned (can recover from mistakes)
#   ✅ Encrypted
#   ✅ Backed up automatically
#
# Cons:
#   ❌ Requires initial S3 setup
#   ❌ Small cost (~$0.03/month)
#
# Good for: Production, teams, important infrastructure
#
# ============================================================================

# Uncomment and configure this block to use S3 backend:

# terraform {
#   backend "s3" {
#     # S3 bucket name - MUST BE GLOBALLY UNIQUE
#     bucket = "mycompany-terraform-state-prod"
#     
#     # Path to state file within bucket
#     key = "vpc/terraform.tfstate"
#     
#     # AWS region where S3 bucket is located
#     region = "us-east-1"
#     
#     # DynamoDB table for state locking
#     dynamodb_table = "terraform-state-lock"
#     
#     # Encrypt state file at rest
#     encrypt = true
#     
#     # Optional: Use versioning (recommended!)
#     # This lets you recover from mistakes
#     # Enable versioning on your S3 bucket
#   }
# }

# ============================================================================
# HOW TO SET UP S3 BACKEND
# ============================================================================
#
# Step 1: Create S3 bucket for state files
# -----------------------------------------
# aws s3api create-bucket \
#   --bucket mycompany-terraform-state-prod \
#   --region us-east-1
#
# Step 2: Enable versioning on the bucket
# -----------------------------------------
# aws s3api put-bucket-versioning \
#   --bucket mycompany-terraform-state-prod \
#   --versioning-configuration Status=Enabled
#
# Step 3: Enable encryption on the bucket
# -----------------------------------------
# aws s3api put-bucket-encryption \
#   --bucket mycompany-terraform-state-prod \
#   --server-side-encryption-configuration '{
#     "Rules": [{
#       "ApplyServerSideEncryptionByDefault": {
#         "SSEAlgorithm": "AES256"
#       }
#     }]
#   }'
#
# Step 4: Create DynamoDB table for locking
# -----------------------------------------
# aws dynamodb create-table \
#   --table-name terraform-state-lock \
#   --attribute-definitions AttributeName=LockID,AttributeType=S \
#   --key-schema AttributeName=LockID,KeyType=HASH \
#   --billing-mode PAY_PER_REQUEST \
#   --region us-east-1
#
# Step 5: Uncomment the backend configuration above
# -----------------------------------------
# Edit this file and uncomment the backend "s3" block
#
# Step 6: Initialize Terraform with new backend
# -----------------------------------------
# terraform init
#
# Terraform will ask: "Do you want to copy existing state to the new backend?"
# Answer: yes
#
# ============================================================================
# WORKING WITH REMOTE STATE
# ============================================================================
#
# Once configured, Terraform automatically:
#   - Downloads state before running
#   - Locks state during operations
#   - Uploads state after changes
#   - Handles versioning
#
# Common commands:
#   terraform init     # Connect to backend
#   terraform plan     # Downloads state, shows changes
#   terraform apply    # Locks, applies changes, uploads state
#
# View state:
#   terraform state list                    # List all resources
#   terraform state show aws_vpc.main      # Show specific resource
#
# ============================================================================
# MIGRATING BETWEEN BACKENDS
# ============================================================================
#
# Local → S3:
#   1. Set up S3 backend (steps above)
#   2. Uncomment backend configuration
#   3. Run: terraform init
#   4. Answer "yes" to copy state
#
# S3 → Different S3:
#   1. Update backend configuration (new bucket name)
#   2. Run: terraform init -migrate-state
#   3. Old state file remains (backup)
#
# ============================================================================
# BEST PRACTICES
# ============================================================================
#
# ✅ DO:
#   - Use remote backend for production
#   - Enable versioning on S3 bucket
#   - Enable encryption
#   - Use DynamoDB locking
#   - Backup state files
#   - Use separate state files for different environments
#
# ❌ DON'T:
#   - Commit terraform.tfstate to Git
#   - Share state files manually
#   - Edit state files directly
#   - Delete state files (very dangerous!)
#   - Use local backend for team projects
#
# ============================================================================
# SECURITY NOTES
# ============================================================================
#
# State files contain sensitive data:
#   - Resource IDs
#   - IP addresses
#   - Sometimes passwords or keys
#
# Protect your state:
#   - Encrypt at rest (S3 encryption)
#   - Encrypt in transit (HTTPS)
#   - Limit access (S3 bucket policy)
#   - Enable versioning (recover from accidents)
#   - Enable logging (audit who accessed state)
#
# ============================================================================
