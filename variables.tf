variable "service_name" {
  description = "Service Name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "ec2_instance_type" { type = string }

variable "username" {
  description = "RDS master username"
  type        = string
}

variable "password" {
  description   = "RDS master password"
  type      = string
  sensitive = true
}
