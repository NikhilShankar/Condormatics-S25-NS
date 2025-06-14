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

#Security Group for load balancer
resource "aws_security_group" "ns_lb_security_group" {
  name   = "ns_lb_security_group"
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

  tags = {
    Name = "9026254_NIKHILSHANKAR_LAB4_SG_LB"
  }
}