resource "aws_security_group" "was" {
  name   = "${var.service_name}-was-sg"
  vpc_id = var.vpc_id

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

  tags = {
    Name        = "${var.service_name}-was-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "this" {
  ami                         = "ami-0ae2c887094315bed"
  instance_type               = var.ec2_instance_type
  subnet_id                   = var.private_subnet_id
  key_name                    = "dummy"
  vpc_security_group_ids      = [aws_security_group.was.id]
  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              set -euo pipefail
              yum update -y
              yum install -y docker
              systemctl enable docker
              systemctl start docker

              # Allow ec2-user to run docker
              usermod -aG docker ec2-user || true

              # Pull and run container
              docker pull yoon11/dummy
              docker run -d -p 8080:8080 --name dummy-app yoon11/dummy
              EOF

  tags = {
    Name        = "${var.service_name}-was"
    Environment = var.environment
  }
}

resource "aws_lb_target_group_attachment" "was_ec2" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.this.id
  port             = 8080
}
