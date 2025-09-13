resource "aws_security_group" "web" {
  name   = "${var.service_name}-web-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
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
    Name        = "${var.service_name}-web-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "this" {
  ami                         = "ami-0ae2c887094315bed"
  instance_type               = "t2.micro" # web server 는 고정
  subnet_id                   = var.private_subnet_id
  key_name                    = "dummy"
  user_data                   = <<-EOF
#!/bin/bash
yum update -y
yum install -y nginx

tee /etc/nginx/conf.d/reverse-proxy.conf > /dev/null <<CONF
server {
  listen 80 default_server;
  listen [::]:80 default_server;

  location /test {
    add_header Content-Type text/plain;
    return 200 "ok";
  }

  location / {
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_pass http://${var.internal_alb_dns_name};
    }
}
CONF

systemctl enable nginx
systemctl restart nginx
EOF
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = false


  tags = {
    Name        = "${var.service_name}-web"
    Environment = var.environment
  }
}

resource "aws_lb_target_group_attachment" "web_ec2" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.this.id
  port             = 80
}