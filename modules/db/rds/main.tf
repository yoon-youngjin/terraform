locals {
  common_tags = {
    Owner       = var.owner
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  })
}

resource "aws_security_group" "db" {
  name   = "${var.project_name}-${var.environment}-db-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "db_inbound_from_sgs" {
  for_each                     = var.allowed_sg_ids
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = each.value
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
}

resource "aws_db_instance" "this" {
  identifier             = "${var.project_name}-${var.environment}-db"
  engine                 = var.engine
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  username               = var.username
  password               = var.password
  skip_final_snapshot    = true # RDS 인스턴스 삭제 시 최종 스냅샷 없이 종료
  multi_az               = false # 단일 AZ에만 배포

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-db"
  })
}