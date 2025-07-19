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
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "Aurora DB subnet group"
  }
}

# Security Group for Aurora
resource "aws_security_group" "aurora_security_group" {
  name        = "aurora_security_group"
  description = "Security group for Aurora database"
  vpc_id      = aws_vpc.db_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
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

# Aurora Cluster
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.02.0"
  availability_zones      = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  database_name           = "mydb"
  master_username         = "admin"
  master_password         = "password123"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  
  vpc_security_group_ids = [aws_security_group.aurora_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name
  
  skip_final_snapshot = true
  
  tags = {
    Name = "aurora-cluster"
  }
}

# Aurora Instance
resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier         = "aurora-instance"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = "db.t3.small"
  engine             = aws_rds_cluster.aurora_cluster.engine
  engine_version     = aws_rds_cluster.aurora_cluster.engine_version
}

# CloudWatch Alarm for Database Read IOPS > 90%
resource "aws_cloudwatch_metric_alarm" "aurora_read_iops_alarm" {
  alarm_name          = "aurora-read-iops-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ReadIOPS"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "900"  # Adjust based on your instance capacity
  alarm_description   = "This metric monitors Aurora read IOPS"
  alarm_actions       = [] # Add SNS topic ARN here for notifications

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora_cluster.cluster_identifier
  }
}

# CloudWatch Alarm for Database Write IOPS > 90%
resource "aws_cloudwatch_metric_alarm" "aurora_write_iops_alarm" {
  alarm_name          = "aurora-write-iops-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "WriteIOPS"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "900"  # Adjust based on your instance capacity
  alarm_description   = "This metric monitors Aurora write IOPS"
  alarm_actions       = [] # Add SNS topic ARN here for notifications

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora_cluster.cluster_identifier
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "aurora_dashboard" {
  dashboard_name = "aurora-mysql-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "ReadIOPS", "DBClusterIdentifier", aws_rds_cluster.aurora_cluster.cluster_identifier],
            ["AWS/RDS", "WriteIOPS", "DBClusterIdentifier", aws_rds_cluster.aurora_cluster.cluster_identifier]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Aurora MySQL - Read/Write IOPS"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBClusterIdentifier", aws_rds_cluster.aurora_cluster.cluster_identifier],
            ["AWS/RDS", "DatabaseConnections", "DBClusterIdentifier", aws_rds_cluster.aurora_cluster.cluster_identifier]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Aurora MySQL - CPU & Connections"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "ReadLatency", "DBClusterIdentifier", aws_rds_cluster.aurora_cluster.cluster_identifier],
            ["AWS/RDS", "WriteLatency", "DBClusterIdentifier", aws_rds_cluster.aurora_cluster.cluster_identifier]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Aurora MySQL - Read/Write Latency"
        }
      }
    ]
  })
}

# Output
output "aurora_cluster_endpoint" {
  value = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_cluster_reader_endpoint" {
  value = aws_rds_cluster.aurora_cluster.reader_endpoint
}

output "dashboard_url" {
  value = "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=${aws_cloudwatch_dashboard.aurora_dashboard.dashboard_name}"
}