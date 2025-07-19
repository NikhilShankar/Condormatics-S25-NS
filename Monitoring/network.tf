# NETWORKING
resource "aws_vpc" "app" {
  cidr_block           = local.cidr_block_vpc
  enable_dns_hostnames = true
}


resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.app.id

  tags = var.resource_tags
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.app.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = var.public_subnet_cidr_blocks[0]
  map_public_ip_on_launch = local.map_public_ip_on_launch
  tags                    = var.resource_tags
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.app.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = var.public_subnet_cidr_blocks[1]
  map_public_ip_on_launch = local.map_public_ip_on_launch
  tags                    = var.resource_tags
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = var.resource_tags
}

resource "aws_route_table_association" "public_subnet_route_table" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet2_route_table" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "public_security_group" {
  name        = "public_security_group"
  description = "FOO BAR"
  vpc_id      = aws_vpc.app.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.cidr_block_vpc]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group" "load_balancer_security_group" {
  name        = "load_balancer_security_grouo"
  description = "FOO BAR"
  vpc_id      = aws_vpc.app.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.resource_tags
}
