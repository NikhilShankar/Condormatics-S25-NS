# INSTANCES
resource "aws_instance" "ns_instance_1" {
  ami           = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type = "t3.micro"
  subnet_id = aws_subnet.ns_public_subnet.id
  vpc_security_group_ids = [aws_security_group.ns_public_security_group.id]  
  tags = {
    Name = "NixacLabs-ServerInstance1"
  }
  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Taco Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span><span style=\"font-size:28px;\">Serving from instance 1 !</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF

}

resource "aws_instance" "ns_instance_2" {

    ami = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
    instance_type = "t3.micro"
    subnet_id = aws_subnet.ns_public_subnet_2.id
    vpc_security_group_ids = [aws_security_group.ns_public_security_group.id]
    tags = {
        Name = "NixacLabs-ServerInstance2"
    }
    user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Taco Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span><span style=\"font-size:28px;\">Serving from instance 2 !</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF
}