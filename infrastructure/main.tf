provider "aws" {
  region = "eu-west-2" # London
}

# Automatically fetch the latest Amazon Linux 2 AMI for eu-west-2
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security group for HTTP + SSH
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "WebAppSG"
  }
}

# EC2 instance using the latest Amazon Linux 2 AMI
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = "feedback-key" # key pair you created in console
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd git
              systemctl start httpd
              systemctl enable httpd
              cd /var/www/html
              git clone https://github.com/Fraser-Brockie/Feedback-Portal.git
              cp -r Feedback-Portal/web-app/* .
              EOF

  tags = {
    Name = "WebAppServer"
  }
}

# Output the public IP so GitHub Actions can use it
output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}