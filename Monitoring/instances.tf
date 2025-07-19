# INSTANCES
resource "aws_instance" "nginx1" {
  ami           = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type = var.instance_type
  cpu_options {
    core_count       = var.core_count
    threads_per_core = var.thread_count
  }

  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_security_group.id]

  tags = var.resource_tags

  depends_on = [aws_iam_role_policy.allow_s3_access_to_ec2]

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/webcontent/index.html /home/ec2-user/index.html
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/webcontent/styles.css /home/ec2-user/styles.css
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/webcontent/campus.jpg /home/ec2-user/campus.jpg
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/webcontent/programs.jpg /home/ec2-user/programs.jpg
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/webcontent/students.jpg /home/ec2-user/students.jpg
sudo rm /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/styles.css /usr/share/nginx/html/styles.css
sudo cp /home/ec2-user/campus.jpg /usr/share/nginx/html/campus.jpg
sudo cp /home/ec2-user/programs.jpg /usr/share/nginx/html/programs.jpg
sudo cp /home/ec2-user/students.jpg /usr/share/nginx/html/students.jpg
EOF
}

resource "aws_instance" "nginx2" {
  ami           = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type = var.instance_type
  cpu_options {
    core_count       = var.core_count
    threads_per_core = var.thread_count
  }

  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  subnet_id              = aws_subnet.public_subnet2.id
  vpc_security_group_ids = [aws_security_group.public_security_group.id]

  tags = var.resource_tags

  depends_on = [aws_iam_role_policy.allow_s3_access_to_ec2]
  user_data  = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/webcontent/index.html /home/ec2-user/index.html
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/webcontent/styles.css /home/ec2-user/styles.css
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/webcontent/campus.jpg /home/ec2-user/campus.jpg
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/webcontent/programs.jpg /home/ec2-user/programs.jpg
aws s3 cp s3://${aws_s3_bucket.web_bucket.id}/webcontent/students.jpg /home/ec2-user/students.jpg
sudo rm /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/styles.css /usr/share/nginx/html/styles.css
sudo cp /home/ec2-user/campus.jpg /usr/share/nginx/html/campus.jpg
sudo cp /home/ec2-user/programs.jpg /usr/share/nginx/html/programs.jpg
sudo cp /home/ec2-user/students.jpg /usr/share/nginx/html/students.jpg
EOF
}

resource "aws_iam_role" "allow_ec2_s3" {
  name = "allow_ec2_s3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = var.resource_tags
}

resource "aws_iam_role_policy" "allow_s3_access_to_ec2" {
  name = "allow_s3_access_to_ec2"
  role = aws_iam_role.allow_ec2_s3.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.web_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.web_bucket.bucket}/*",
        ]
      },
    ]
  })
}

resource "aws_iam_instance_profile" "nginx_profile" {
  name = "nginx_profile"
  role = aws_iam_role.allow_ec2_s3.name
  tags = var.resource_tags
}