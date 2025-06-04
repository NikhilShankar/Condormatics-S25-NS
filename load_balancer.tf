#LoadBalancer
resource "aws_lb" "niks_nginx_lb" {
  name = "prog8830-lb-tf"
  internal = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.ns_lb_security_group.id]
  subnets = [aws_subnet.ns_public_subnet.id]

  tags = {
    Name = "9026254_NIKHILSHANKAR_LAB4"
  }

}

#TARGET GROUP
resource "aws_lb_target_group" "niks_lb_target_group" {
  name     = "niks-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ns_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "9026254_NIKHILSHANKAR_LAB4_TG"
  }
}


#LISTENER
resource "aws_lb_listener" "niks_lb_listener" {
  load_balancer_arn = aws_lb.niks_nginx_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.niks_lb_target_group.arn
  }

  tags = {
    Name = "9026254_NIKHILSHANKAR_LAB4_LISTENER"
  }
  
}


#Group Attachments
resource "aws_lb_target_group_attachment" "niks_lb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.niks_lb_target_group.arn
  target_id        = aws_instance.ns_nginx1.id
  port             = 80
}

#Group Attachments
resource "aws_lb_target_group_attachment" "niks_lb_target_group_attachment_2" {
  target_group_arn = aws_lb_target_group.niks_lb_target_group.arn
  target_id        = aws_instance.ns_nginx2.id
  port             = 80
}