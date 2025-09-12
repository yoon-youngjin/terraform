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

  service_name = var.service_name
  vpc_cidr     = "10.23.0.0/16"
  environment  = var.environment
}

module "external_alb" {
  source = "./modules/lb"

  service_name = var.service_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id
  isInternal   = false
  subnet_ids   = module.network.public_subnet_ids
}

module "web" {
  source = "./modules/web"

  service_name          = var.service_name
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  private_subnet_id     = module.network.web_private_subnet_ids[0] # 일단 한개만 생성
  target_group_arn      = module.external_alb.alb_target_group_arn
  alb_security_group_id = module.external_alb.alb_security_group_id
  internal_alb_dns_name = module.internal_alb.alb_dns_name
}

module "internal_alb" {
  source = "./modules/lb"

  service_name      = var.service_name
  environment       = var.environment
  vpc_id            = module.network.vpc_id
  isInternal        = true
  subnet_ids        = module.network.web_private_subnet_ids
  target_group_port = "8080"
}

module "was" {
  source = "./modules/was"

  service_name          = var.service_name
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  private_subnet_id     = module.network.was_private_subnet_ids[0] # 일단 한개만 생성
  target_group_arn      = module.internal_alb.alb_target_group_arn
  alb_security_group_id = module.internal_alb.alb_security_group_id
  ec2_instance_type     = var.ec2_instance_type
}

module "db" {
  source = "./modules/db"

  service_name      = var.service_name
  environment       = var.environment
  vpc_id            = module.network.vpc_id
  allowed_sg_ids    = [module.was.was_security_group_id]
  private_subnet_ids = module.network.db_private_subnet_ids
  username          = var.username
  password          = var.password
}