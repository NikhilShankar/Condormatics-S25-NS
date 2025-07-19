provider "aws" {
  region = "us-east-1"
}

resource "aws_lb" "ns_lb" {
  name               = "ns-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ns_lb_security_group.id]
  subnets            = values(aws_subnet.ns_public_subnet)[*].id

  enable_deletion_protection = false

  tags = {
    Name = "Nixaclabs-LoadBalancer"
  }
}

resource "aws_lb_target_group" "ns_lb_target_group" {
  name     = "ns-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ns_vpc.id

  tags = {
    Name = "NS-LB-Target-Group"
  }
}

# Target group attachments using for_each to attach all instances
resource "aws_lb_target_group_attachment" "ns_lb_target_group_attachment" {
  for_each = aws_instance.ns_instance
  
  target_group_arn = aws_lb_target_group.ns_lb_target_group.arn
  target_id        = each.value.id
  port             = 80
}

resource "aws_lb_listener" "ns_lb_listener" {
  load_balancer_arn = aws_lb.ns_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ns_lb_target_group.arn
  }
}

output "load_balancer_url" {
  description = "Full URL of the load balancer"
  value       = "http://${aws_lb.ns_lb.dns_name}"
}