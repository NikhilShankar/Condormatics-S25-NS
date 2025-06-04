

# Internet GW 
resource "aws_internet_gateway" "ns_internet_gateway" {
  vpc_id = aws_vpc.ns_vpc.id

  tags = {
    Name = "IGW-CondorMatics-S25-NS"
  }
}


# Subnet 

resource "aws_subnet" "ns_public_subnet" {
  vpc_id                  = aws_vpc.ns_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
}

# Route Table 
resource "aws_route_table" "ns_public_route_table" {
  vpc_id = aws_vpc.ns_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ns_internet_gateway.id
  }
}

# Route Table Association 
resource "aws_route_table_association" "public_subnet_route_table" {
  subnet_id      = aws_subnet.ns_public_subnet.id
  route_table_id = aws_route_table.ns_public_route_table.id
}
