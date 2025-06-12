provider "aws" {
  region = "us-east-1"
}

# DATA
data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# RESOURCES

# NETWORKING
resource "aws_vpc" "ns_vpc" {
  cidr_block           = "10.0.1.0/24"
  enable_dns_hostnames = true

}

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

# Security Group 

resource "aws_security_group" "ns_public_security_group" {
  name   = "ns_public_security_group"
  vpc_id = aws_vpc.ns_vpc.id

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
}


# INSTANCES
resource "aws_instance" "ns_nginx1" {
  ami           = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type = "t3.micro"
  availability_zone = "us-east-1a"
  subnet_id = aws_subnet.ns_public_subnet.id
  vpc_security_group_ids = [aws_security_group.ns_public_security_group.id]  
  tags = {
    Name = "9026254_NIKHILSHANKAR_LAB3"
  }
  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Taco Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF

}
