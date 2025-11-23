provider "aws" {
  region = "eu-west-2" # London region
}

# Key pair for SSH access
resource "aws_key_pair" "feedback_key" {
  key_name   = "feedback-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Security group with lifecycle rules
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

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }

  tags = {
    Name = "WebAppSG"
  }
}

# EC2 instance with user data to install Apache and pull app
resource "aws_instance" "web" {
  ami           = "ami-0d729d2846a86a9a8" # Amazon Linux 2 AMI for eu-west-2 (London)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.feedback_key.key_name
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

  depends_on = [aws_security_group.web_sg]
}