variable "owner" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "isInternal" {
  type = bool
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "target_group_port" {
  type    = string
  default = "80"
}

variable "domain_name" {
  type    = string
  default = "*.dummycash.com"
}

variable "acm_certificate_arn" {
  type = string
}