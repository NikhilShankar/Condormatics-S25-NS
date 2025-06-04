# NETWORKING
resource "aws_vpc" "ns_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

provider "aws" {
  region = "us-east-1"
}

# DATA
data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
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
