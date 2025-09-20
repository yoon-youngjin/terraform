terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.16"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "ap-northeast-2"
}

module "network" {
  source = "./modules/network"

  service_name     = var.service_name
  vpc_cidr         = "10.23.0.0/16"
  environment      = var.environment
  allowed_ssh_cidr = var.allowed_ssh_cidrs[0]
}

module "external_alb" {
  source = "./modules/app-deployment-stack/lb"

  service_name        = var.service_name
  environment         = var.environment
  vpc_id              = module.network.vpc_id
  isInternal          = false
  subnet_ids          = module.network.public_subnet_ids
  target_group_port   = "80"
  acm_certificate_arn = var.acm_certificate_arn
}

module "bastion" {
  source = "./modules/bastion"

  service_name      = var.service_name
  environment       = var.environment
  public_subnet_id  = module.network.public_subnet_ids[0]
  vpc_id            = module.network.vpc_id
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
}

module "was" {
  source = "./modules/app-deployment-stack/was"

  service_name              = var.service_name
  environment               = var.environment
  vpc_id                    = module.network.vpc_id
  private_subnet_id         = module.network.was_private_subnet_ids[0] # 일단 한개만 생성
  target_group_arn          = module.external_alb.alb_target_group_arn
  alb_security_group_id     = module.external_alb.alb_security_group_id
  ec2_instance_type         = var.ec2_instance_type
  bastion_security_group_id = module.bastion.bastion_security_group_id
}

module "db" {
  source = "./modules/db"

  service_name   = var.service_name
  environment    = var.environment
  vpc_id         = module.network.vpc_id
  allowed_sg_ids = {
    was     = module.was.was_security_group_id
    bastion = module.bastion.bastion_security_group_id
  }
  private_subnet_ids = module.network.db_private_subnet_ids
  username           = var.username
  password           = var.password
}