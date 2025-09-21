locals {
  common_tags = {
    Owner       = var.owner
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_security_group" "bastion" {
  name   = "${var.project_name}-${var.environment}-bastion-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-bastion-sg"
  })
}

resource "aws_instance" "this" {
  ami           = "ami-0ae2c887094315bed"
  instance_type = "t2.micro" # bastion server 는 고정
  subnet_id     = var.public_subnet_id
  key_name      = "dummy"

  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-bastion"
  })
}
