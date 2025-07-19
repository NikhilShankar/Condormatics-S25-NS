# NETWORKING
resource "aws_vpc" "app" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

}

# Internet GW 
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "IGW-CondorMatics-S25"
  }
}

resource "aws_subnet" "postgres_subnet" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "pg-subnet-1"
  }
}

resource "aws_subnet" "pg_subnet_2" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  
  tags = {
    Name = "pg-subnet-2"
  }
}

resource "aws_db_subnet_group" "pg_subnet_group" {
  name       = "pg_subnet_group"
  subnet_ids = [aws_subnet.postgres_subnet.id, aws_subnet.pg_subnet_2.id]
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
  subnet_id      = aws_subnet.postgres_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Add this to network.tf
resource "aws_route_table_association" "public_subnet_route_table_2" {
  subnet_id      = aws_subnet.pg_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}