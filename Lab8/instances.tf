locals {
  subnet_ids = values(aws_subnet.ns_public_subnet)[*].id
  subnet_count = length(local.subnet_ids)
  
  instances = {
    "1" = { subnet_index = 0 }
    "2" = { subnet_index = 1 % local.subnet_count }
    "3" = { subnet_index = 2 % local.subnet_count }
  }
  
  project_prefix = "${lower(var.project_name)}-${formatdate("MM-DD", timestamp())}"
}

resource "aws_instance" "ns_instance" {
  for_each = local.instances
  
  ami           = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type = "t3.micro"
  
  subnet_id = local.subnet_ids[each.value.subnet_index]
  
  vpc_security_group_ids = [aws_security_group.ns_public_security_group.id]
  
  tags = {
    Name = "${local.project_prefix}-ServerInstance${each.key}"
    Project = var.project_name
    CreatedDate = formatdate("MM-DD-YYYY", timestamp())
  }
  
  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Taco Team Server</title></head><body style="background-color:#1F778D"><p style="text-align: center;"><span style="color:#FFFFFF;"><span style="font-size:28px;">You did it! Have a &#127790;</span><span style="font-size:28px;">Serving from instance ${each.key}!</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF
}