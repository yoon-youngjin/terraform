variable "vpc_cidr" {
  description = "IPv4 CIDR Block"
  type        = string
}

variable "service_name" {
  description = "Service Name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "az_names" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}
