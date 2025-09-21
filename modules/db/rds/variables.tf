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

variable "private_subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "allowed_sg_ids" {
  type = map(string)
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "engine" {
  type    = string
  default = "mysql"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "username" {
  type = string
}

variable "password" {
  type = string
}