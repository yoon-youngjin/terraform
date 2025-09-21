# 공용 변수
variable "owner" {
  description = "The team responsible for managing this resource"
  type        = string
}

variable "project_name" {
  default = "Project Name"
  type    = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

# msa 전용 변수
variable "service_name" {
  description = "Service Name"
  type        = string
}

variable "platform" {
  description = "Platform(Spring Boot, Node.js, ...)"
  type        = string
}

variable "github_url" {
  description = "Github URL"
  type        = string
}

variable "ec2_instance_type" { type = string }

# DB 전용 변수
variable "username" {
  description = "RDS master username"
  type        = string
}

variable "password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

# 네트워크 전용 변수
variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into bastion host"
  type        = list(string)
}

variable "acm_certificate_arn" {
  type = string
}