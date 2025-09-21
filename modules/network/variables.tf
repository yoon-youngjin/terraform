variable "owner" {
  type = string
}

variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR Block"
  type        = string
}

variable "az_names" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "allowed_ssh_cidr" {
  type = string
}
