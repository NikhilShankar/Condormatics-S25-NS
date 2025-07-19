# NETWORKING
resource "aws_vpc" "ns_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "ns_internet_gateway" {
  vpc_id = aws_vpc.ns_vpc.id

  tags = {
    Name = "NixacLabs-IGW"
  }
}

locals {
  available_azs_count = length(data.aws_availability_zones.available.names)
  max_azs_to_use = min(3, local.available_azs_count)
  min_azs_required = max(1, local.max_azs_to_use)
  
  subnet_configs = {
    for i in range(local.max_azs_to_use) : 
    "subnet${i + 1}" => {
      cidr_block = cidrsubnet(aws_vpc.ns_vpc.cidr_block, 8, i + 1)
      az_index   = i
    }
  }
}

resource "aws_subnet" "ns_public_subnet" {
  for_each = local.subnet_configs
  
  vpc_id                  = aws_vpc.ns_vpc.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[each.value.az_index]
  
  tags = {
    Name = "NixacLabs-PublicSubnet-${each.key}"
  }
}

resource "aws_route_table" "ns_public_route_table" {
  vpc_id = aws_vpc.ns_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ns_internet_gateway.id
  }
}

resource "aws_route_table_association" "public_subnet_route_table" {
  for_each = aws_subnet.ns_public_subnet
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.ns_public_route_table.id
}