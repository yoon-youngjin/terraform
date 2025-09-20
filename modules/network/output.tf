output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the created VPC"
  value       = aws_vpc.this.cidr_block
}

output "igw_id" {
  description = "ID of the created Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "was_private_subnet_ids" {
  description = "ID of was private subnets"
  value       = [for s in aws_subnet.was_private_subnet : s.id]
}

output "db_private_subnet_ids" {
  description = "ID of db private subnets"
  value       = [for s in aws_subnet.db_private_subnet : s.id]
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public_subnet : s.id]
}
