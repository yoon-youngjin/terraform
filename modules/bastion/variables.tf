variable "service_name" {
  description = "Service Name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "vpc_id" { type = string }

variable "public_subnet_id" { type = string }

variable "allowed_ssh_cidrs" {
  type = list(string)
}