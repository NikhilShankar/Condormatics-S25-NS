locals {
  default_region          = "us-east-1"
  amzn2_linux_ami_name    = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
  cidr_block_vpc          = "10.0.0.0/16"
  map_public_ip_on_launch = true
  s3_bucket_name          = "conestoga-prog8830-${random_integer.s3_bucket_suffix.result}"
}


output "s3_bucket_name" {
  value = local.s3_bucket_name
}
