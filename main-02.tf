terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -------------------------------
# PROVIDERS
# -------------------------------

# Mumbai Provider
provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

# North Virginia Provider
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

# -------------------------------
# SECURITY GROUP - MUMBAI
# -------------------------------

resource "aws_security_group" "mumbai_sg" {
  provider = aws.mumbai
  name     = "mumbai-nginx-sg"

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

# -------------------------------
# SECURITY GROUP - VIRGINIA
# -------------------------------

resource "aws_security_group" "virginia_sg" {
  provider = aws.virginia
  name     = "virginia-nginx-sg"

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

# -------------------------------
# EC2 - MUMBAI
# -------------------------------

resource "aws_instance" "mumbai_ec2" {
  provider      = aws.mumbai
  ami           = "ami-0f58b397bc5c1f2e8"   # Amazon Linux 2023 - Mumbai
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.mumbai_sg.id]

  user_data = <<-EOF
#!/bin/bash
dnf update -y
dnf install -y nginx
systemctl enable nginx
systemctl start nginx
EOF

  tags = {
    Name = "Mumbai-Nginx-Server"
  }
}

# -------------------------------
# EC2 - VIRGINIA
# -------------------------------

resource "aws_instance" "virginia_ec2" {
  provider      = aws.virginia
  ami           = "ami-0e86e20dae9224db8"   # Amazon Linux 2023 - Virginia
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.virginia_sg.id]

  user_data = <<-EOF
#!/bin/bash
dnf update -y
dnf install -y nginx
systemctl enable nginx
systemctl start nginx
EOF

  tags = {
    Name = "Virginia-Nginx-Server"
  }
}

# -------------------------------
# OUTPUTS
# -------------------------------

output "mumbai_public_ip" {
  value = aws_instance.mumbai_ec2.public_ip
}

output "virginia_public_ip" {
  value = aws_instance.virginia_ec2.public_ip
}
