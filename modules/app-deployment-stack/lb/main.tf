locals {
  common_tags = {
    Owner       = var.owner
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_security_group" "alb" {
  name   = "${var.project_name}-${var.environment}-external-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-external-alb-sg"
  })
}

resource "aws_lb" "alb" {
  name               = "${var.project_name}-${var.environment}-external-alb"
  load_balancer_type = "application"
  internal           = var.isInternal
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-external-alb"
  })
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.project_name}-${var.environment}-external-tg"
  port     = var.target_group_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-external-tg"
  })
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
