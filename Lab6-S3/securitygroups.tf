# Security Group 


#This security group is to be used by the instances that will be behind the load balancer.
resource "aws_security_group" "ns_public_security_group" {
  name   = "ns_public_security_group"
  vpc_id = aws_vpc.ns_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.ns_lb_security_group.id] # Allow traffic from the Load Balancer security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for the Load Balancer
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
    name = "NixacLabs-LB-Security-Group"
  }
}
