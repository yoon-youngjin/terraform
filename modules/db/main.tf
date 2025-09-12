resource "aws_db_subnet_group" "this" {
  name       = "${var.service_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.service_name}-db-subnet-group"
    Environment = var.environment
  }
}

resource "aws_security_group" "db" {
  name   = "${var.service_name}-db-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.service_name}-db-sg"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_inbound_from_sg" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = var.allowed_sg_ids[0]
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
}

resource "aws_db_instance" "this" {
  identifier             = "${var.service_name}-db"
  engine                 = var.engine
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  username               = var.username
  password               = var.password
  skip_final_snapshot    = true # RDS 인스턴스 삭제 시 최종 스냅샷 없이 종료
  multi_az               = false # 단일 AZ에만 배포

  tags = {
    Name        = "${var.service_name}-db"
    Environment = var.environment
  }
}