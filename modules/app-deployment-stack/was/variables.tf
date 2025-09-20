variable "service_name" {
  description = "Service Name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "vpc_id" { type = string }

variable "private_subnet_id" { type = string }

variable "target_group_arn" { type = string }

variable "alb_security_group_id" { type = string }

variable "ec2_instance_type" { type = string }

variable "bastion_security_group_id" { type = string }

variable "asg_min_capacity" {
  type    = number
  default = 1
}

variable "asg_max_capacity" {
  type    = number
  default = 1
}

variable "asg_desired_capacity" {
  type    = number
  default = 1
}