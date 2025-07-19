# Provider
provider "aws" {
  region = "us-east-1"
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "db_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# Private Subnets for RDS (required for DB subnet group)
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.db_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.1.0/24"
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.db_vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "10.0.2.0/24"
}

# DB Subnet Group
resource "aws_db_subnet_group" "aurora_postgres_subnet_group" {
  name       = "aurora-postgres-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "Aurora PostgreSQL DB subnet group"
  }
}

# Security Group for Aurora PostgreSQL
resource "aws_security_group" "aurora_postgres_security_group" {
  name        = "aurora_postgres_security_group"
  description = "Security group for Aurora PostgreSQL database"
  vpc_id      = aws_vpc.db_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Aurora PostgreSQL Cluster
resource "aws_rds_cluster" "aurora_postgres_cluster" {
  cluster_identifier      = "aurora-postgres-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "15.4"
  availability_zones      = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  database_name           = "mydb"
  master_username         = "postgres"
  master_password         = "password123"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  
  vpc_security_group_ids = [aws_security_group.aurora_postgres_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.aurora_postgres_subnet_group.name
  
  skip_final_snapshot = true
  
  tags = {
    Name = "aurora-postgres-cluster"
  }
}

# Aurora PostgreSQL Instance
resource "aws_rds_cluster_instance" "aurora_postgres_instance" {
  identifier         = "aurora-postgres-instance"
  cluster_identifier = aws_rds_cluster.aurora_postgres_cluster.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.aurora_postgres_cluster.engine
  engine_version     = aws_rds_cluster.aurora_postgres_cluster.engine_version
}

# CloudWatch Alarm for Database Read IOPS > 90%
resource "aws_cloudwatch_metric_alarm" "aurora_postgres_read_iops_alarm" {
  alarm_name          = "aurora-postgres-read-iops-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ReadIOPS"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1800"  # Adjust based on your instance capacity
  alarm_description   = "This metric monitors Aurora PostgreSQL read IOPS"
  alarm_actions       = [] # Add SNS topic ARN here for notifications

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora_postgres_cluster.cluster_identifier
  }
}

# CloudWatch Alarm for Database Write IOPS > 90%
resource "aws_cloudwatch_metric_alarm" "aurora_postgres_write_iops_alarm" {
  alarm_name          = "aurora-postgres-write-iops-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "WriteIOPS"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1800"  # Adjust based on your instance capacity
  alarm_description   = "This metric monitors Aurora PostgreSQL write IOPS"
  alarm_actions       = [] # Add SNS topic ARN here for notifications

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora_postgres_cluster.cluster_identifier
  }
}

# CloudWatch Alarm for Database Connection Count > 90%
resource "aws_cloudwatch_metric_alarm" "aurora_postgres_connections_alarm" {
  alarm_name          = "aurora-postgres-connections-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"  # 90% of max connections for db.t3.medium
  alarm_description   = "This metric monitors Aurora PostgreSQL database connections"
  alarm_actions       = [] # Add SNS topic ARN here for notifications

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora_postgres_cluster.cluster_identifier
  }
}

# Output
output "aurora_postgres_cluster_endpoint" {
  value = aws_rds_cluster.aurora_postgres_cluster.endpoint
}

output "aurora_postgres_cluster_reader_endpoint" {
  value = aws_rds_cluster.aurora_postgres_cluster.reader_endpoint
}

output "aurora_postgres_port" {
  value = aws_rds_cluster.aurora_postgres_cluster.port
}