provider "aws" {
  region = "eu-west-2" # London
}

resource "aws_instance" "web" {
  ami           = "ami-0f29c8402f8cce65c" # Amazon Linux 2 in London
  instance_type = "t2.micro"
  key_name      = "feedback-key"          # must match your AWS key pair

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