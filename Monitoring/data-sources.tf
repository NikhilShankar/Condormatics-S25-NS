# DATA
data "aws_ssm_parameter" "amzn2_linux" {
  name = local.amzn2_linux_ami_name
}

# List of supported availability zones in your region
data "aws_availability_zones" "available" {
  state = "available"
}