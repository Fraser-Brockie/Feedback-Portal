provider "aws" {
  region = "eu-west-2" # London
}

# Automatically fetch the latest Amazon Linux 2 AMI in London
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = "feedback-key" # must match your AWS key pair name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              echo "Apache is running" > /var/www/html/index.html
            EOF

  tags = {
    Name = "FeedbackDemoInstance"
  }
}

output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}