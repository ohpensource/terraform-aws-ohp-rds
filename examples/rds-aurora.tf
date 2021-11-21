data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

variable "group" {
  description = "only variable to group resources under the same prefix"
  type        = string
  default     = "dev"
}

locals {
  name        = "ohp-rds-${var.group}"
  account_id  = "215333367418"
  region      = "eu-west-1"
  environment = "int"

  tfm_x_acc_role_name = "xops-tfm-adm-x-acc-role"
  tfm_deploy_role_arn = "arn:aws:iam::${local.account_id}:role/${local.tfm_x_acc_role_name}-${local.environment}"
}

terraform {
  required_version = "~>0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~>2.0"
    }
  }
}



module "rds_aurora" {
  source                = "../modules/rdsaurora"
  name                  = "rds-aurora-dev" #local.name
  engine                = "aurora-mysql"
  engine_version        = "5.7.12"
  instance_type         = "db.r5.large"
  instance_type_replica = "db.t3.medium"

  vpc_id                = var.vpc_id
  db_subnet_group_name  = "db subnet group" #["10.100.5.0/27", "10.100.5.32/27"]
  create_security_group = true
  allowed_cidr_blocks   = ["10.100.1.0/24", "10.100.2.0/24"]
  kms_key_id            = "arn:aws:kms:eu-west-1:720578572654:key/794818c1-5a2f-4cb0-8668-8517bdb5a572"

  replica_count                       = 1
  iam_database_authentication_enabled = true
  password                            = "Password1234" #var.password
  create_random_password              = false

  apply_immediately   = true
  skip_final_snapshot = true

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  family = "aurora-mysql5.7"

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Account_ID  = data.aws_caller_identity.current.account_id # Tags example
    Created_by  = data.aws_caller_identity.current.arn
  }
}
