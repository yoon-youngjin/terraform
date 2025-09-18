output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.tg.arn
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.alb.arn
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}