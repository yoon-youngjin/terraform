locals {
  common_tags = {
    Owner       = var.owner
    Service     = var.service_name
    Environment = var.environment
  }
}

resource "aws_security_group" "was" {
  name   = "${var.service_name}-${var.environment}-was-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.service_name}-${var.environment}-was-sg"
  })
}

data "aws_ami" "standard" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["standard-ami"]
  }
  filter {
    name   = "tag:Environment"
    values = [var.environment]
  }

  owners = ["self"]
}

resource "aws_launch_template" "was" {
  name_prefix   = "${var.service_name}-${var.environment}-lt"
  image_id      = data.aws_ami.standard.id
  instance_type = var.ec2_instance_type
  key_name      = "dummy"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.was.id]
    delete_on_termination       = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags, {
      Name       = "${var.service_name}-${var.environment}-was"
      Platform   = var.platform
      Github_Url = var.github_url
    })
  }
}

resource "aws_autoscaling_group" "was" {
  name                = "${var.service_name}-${var.environment}-asg"
  vpc_zone_identifier = [var.private_subnet_id]
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"

  min_size         = var.asg_min_capacity
  max_size         = var.asg_max_capacity
  desired_capacity = var.asg_desired_capacity

  launch_template {
    id      = aws_launch_template.was.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Owner"
    propagate_at_launch = false
    value               = var.owner
  }

  tag {
    key                 = "Service"
    propagate_at_launch = false
    value               = var.service_name
  }

  tag {
    key                 = "Environment"
    propagate_at_launch = false
    value               = var.environment
  }

  tag {
    key                 = "Name"
    propagate_at_launch = false
    value               = "${var.service_name}-${var.environment}-asg"
  }
}
