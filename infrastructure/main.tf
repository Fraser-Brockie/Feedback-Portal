terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2" # London
}

# Security group with stable name
resource "aws_security_group" "web_sg" {
  name        = "feedback-sg"
  description = "Allow HTTP and SSH"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Latest Amazon Linux 2 AMI
data "aws_ami" "amazonlinux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# EC2 instance with Apache
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "feedback-key"   # <-- use the exact key pair name you created in AWS
  user_data              = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl enable httpd
    echo "<h1>Apache is running</h1>" > /var/www/html/index.html
    systemctl start httpd
  EOF
}

# Output the public IP so Actions can use it
output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}