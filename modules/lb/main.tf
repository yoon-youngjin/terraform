resource "aws_security_group" "alb" {
  name   = "${var.service_name}-external-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.service_name}-external-alb-sg"
    Environment = var.environment
  }
}

resource "aws_lb" "alb" {
  name               = "${var.service_name}-external-alb"
  load_balancer_type = "application"
  internal           = var.isInternal
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  tags = {
    Name        = "${var.service_name}-external-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.service_name}-external-tg"
  port     = var.target_group_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = var.isInternal ? "/health" : "/test"
  }

  tags = {
    Name        = "${var.service_name}-external-tg"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
