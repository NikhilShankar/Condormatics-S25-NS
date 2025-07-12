# NETWORKING
resource "aws_vpc" "ns_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# Internet GW 
resource "aws_internet_gateway" "ns_internet_gateway" {
  vpc_id = aws_vpc.ns_vpc.id

  tags = {
    Name = "NixacLabs-IGW"
  }
}


# Subnet for the first instance in one availability zone
resource "aws_subnet" "ns_public_subnet" {
  vpc_id                  = aws_vpc.ns_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0] #Instead of hardcoding setting it to first availability zone"us-east-1a"
}

# Subnet for the second instance in another availability zone
resource "aws_subnet" "ns_public_subnet_2" {
  vpc_id                  = aws_vpc.ns_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[1] #Instead of hardcoding setting it to second availability zone"us-east-1b"
}

# Route Table 
resource "aws_route_table" "ns_public_route_table" {
  vpc_id = aws_vpc.ns_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ns_internet_gateway.id
  }
}

# Route Table Association for first subnet
resource "aws_route_table_association" "public_subnet_route_table" {
  subnet_id      = aws_subnet.ns_public_subnet.id
  route_table_id = aws_route_table.ns_public_route_table.id
}

# Route Table Association for second subnet
resource "aws_route_table_association" "public_subnet_route_table_2" {
  subnet_id      = aws_subnet.ns_public_subnet_2.id
  route_table_id = aws_route_table.ns_public_route_table.id
}