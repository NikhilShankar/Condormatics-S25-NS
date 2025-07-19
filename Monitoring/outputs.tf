output "load_balancer_public_dns" {
  value = "http://${aws_lb.nginx.dns_name}"
}

output "availability_zones" {
  value = data.aws_availability_zones.available.names
}