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
  ami           = data.aws_ami.amazonlinux.id
  instance_type = "t3.micro"
  key_name      = "feedback-key"   # must match the key pair you created in AWS
  user_data     = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl enable httpd
    echo "<h1>Feedback app is live!</h1>" > /var/www/html/index.html
    systemctl start httpd
  EOF
}

output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}