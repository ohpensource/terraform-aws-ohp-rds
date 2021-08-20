data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

variable "group" {
  description = "only variable to group resources under the same prefix"
  type        = string
  default     = "dev"
}

locals {
  name        = "ohp-elasticache-${var.group}"
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

provider "aws" {
  region              = local.region
  allowed_account_ids = [local.account_id]
  assume_role {
    role_arn     = local.tfm_deploy_role_arn
    session_name = "terraform"
  }
}


module "elasticache_function" {
  source                = "../../modules/redis"
  enable_module         = true #Set to true to create elasticache function
  availability_zones    = ["eu-west-1a", "eu-west-1b"]
  name                  = "redis-dev"
  #subnets                    = var.subnets
  #cluster_size               = 1
  cluster_mode_enabled  = true
  instance_type         = "cache.t2.micro"
  #apply_immediately          = true
  #automatic_failover_enabled = true   #Only set to true when not using T1/T2 instances
  engine_version        = "5.0.6"
  family                = "redis5.0"
  #transit_encryption_enabled = var.transit_encryption_enabled
  kms_key_id            = "arn:aws:kms:eu-west-1:0611111111:key/1232432435435"
  cluster_mode_replicas_per_node_group = 1
  cluster_mode_num_node_groups = 2

  tags = {
           Terraform = "true"
          Environment = "default"
          Account_ID = data.aws_caller_identity.current.account_id      # Tags example
          Created_by = data.aws_caller_identity.current.arn
          }

  parameter = [
    {
      name  = "notify-keyspace-events"
      value = "lK"
    }
  ]
}