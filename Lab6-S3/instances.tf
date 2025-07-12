# INSTANCES
resource "aws_instance" "ns_instance_1" {
  ami           = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type = "t3.micro" // "t3.micro"
  subnet_id = aws_subnet.ns_public_subnet.id
  security_groups = [aws_security_group.ns_public_security_group.id]  
  tags = {
    Name = "NixacLabs-ServerInstance1"
  }
  user_data = <<EOF
  #! /bin/bash

  sudo amazon-linux-extras install -y nginx1
  sudo service nginx start

  # aws s3 cp -r s3://${aws_s3_bucket.web_bucket.id}/webcontent/  /home/ec2-user/
  aws s3 sync  s3://${aws_s3_bucket.web_bucket.id}/webcontent/  /home/ec2-user/

  sudo rm /usr/share/nginx/html/index.html

  sudo cp /home/ec2-user/index.html  /usr/share/nginx/html/index.html
  sudo cp /home/ec2-user/styles.css  /usr/share/nginx/html/styles.css
  sudo cp /home/ec2-user/campus.jpg  /usr/share/nginx/html/campus.jpg
  sudo cp /home/ec2-user/students.jpg  /usr/share/nginx/html/students.jpg
  sudo cp /home/ec2-user/programs.jpg  /usr/share/nginx/html/programs.jpg
EOF
  iam_instance_profile = aws_iam_instance_profile.nginx_profile.name

}

resource "aws_instance" "ns_instance_2" {

    ami = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
    instance_type = "t3.micro" // "t3.micro"
    subnet_id = aws_subnet.ns_public_subnet_2.id
    security_groups = [aws_security_group.ns_public_security_group.id]
    tags = {
        Name = "NixacLabs-ServerInstance2"
    }
    user_data = <<EOF
  #! /bin/bash

  sudo amazon-linux-extras install -y nginx1
  sudo service nginx start

  # aws s3 cp -r s3://${aws_s3_bucket.web_bucket.id}/webcontent/  /home/ec2-user/
  aws s3 sync  s3://${aws_s3_bucket.web_bucket.id}/webcontent/  /home/ec2-user/

  sudo rm /usr/share/nginx/html/index.html

  sudo cp /home/ec2-user/index.html  /usr/share/nginx/html/index.html
  sudo cp /home/ec2-user/styles.css  /usr/share/nginx/html/styles.css
  sudo cp /home/ec2-user/campus.jpg  /usr/share/nginx/html/campus.jpg
  sudo cp /home/ec2-user/students.jpg  /usr/share/nginx/html/students.jpg
  sudo cp /home/ec2-user/programs.jpg  /usr/share/nginx/html/programs.jpg
EOF

    iam_instance_profile = aws_iam_instance_profile.nginx_profile.name

}


resource "aws_iam_instance_profile" "nginx_profile" {
  name = "nginx-profile"
  role = "LabRole"
}