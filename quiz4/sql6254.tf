#Terraform configuration
terraform {
  required_version = ">=1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# List of supported availability zones 
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC 
resource "aws_vpc" "app" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# Internet GW 
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "Quiz-4-SQL"
  }
}

resource "aws_subnet" "sql_subnet_1" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "sql-subnet-1"
  }
}

resource "aws_subnet" "sql_subnet_2" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  
  tags = {
    Name = "sql-subnet-2"
  }
}

resource "aws_db_subnet_group" "sql_subnet_group" {
  name       = "sql_subnet_group"
  subnet_ids = [aws_subnet.sql_subnet_1.id, aws_subnet.sql_subnet_2.id]
}


# Route Table 
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

# Route Table Association 
resource "aws_route_table_association" "public_subnet_route_table" {
  subnet_id      = aws_subnet.sql_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Add this to network.tf
resource "aws_route_table_association" "public_subnet_route_table_2" {
  subnet_id      = aws_subnet.sql_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}


# Security Group for Aurora
resource "aws_security_group" "sql_security_group" {
  name   = "rds_sql"
  vpc_id = aws_vpc.app.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


# RDS CLUSTER and SQL Instance
resource "aws_rds_cluster" "mysql_cluster" {
    engine = "mysql"
    engine_version = "16.6"
    database_name = "quiz4db"
    db_subnet_group_name = aws_db_subnet_group.sql_subnet_group.name
    vpc_security_group_ids = [aws_security_group.sql_security_group.id]
    master_username = "admin-user"
    master_password = "pass4569"
    skip_final_snapshot=true
    apply_immediately = true
    allocated_storage = 30
    db_cluster_parameter_group_name = "custom-mysql-config"
}

resource "aws_rds_cluster_instance" "mysql_instance" {
    cluster_identifier = aws_rds_cluster.mysql_cluster.id
    instance_class = "db.t3.medium"
    engine = aws_rds_cluster.mysql_cluster.engine
    engine_version = aws_rds_cluster.mysql_cluster.engine_version
    publicly_accessible = true
}

resource "aws_rds_cluster_parameter_group" "custom_mysql_config" {
  name   = "custom-mysql-config"
  family = "mysql8.0"

  parameter {
    name  = "max_connections"
    value = "250"
  }

}