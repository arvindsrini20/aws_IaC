
# AWS Provider Configuration
# This block configures Terraform to deploy resources in Amazon Web Services (AWS).
provider "aws" {
  # Specifies the AWS region where all resources will be created.
  region = "us-east-1" # (insert your AWS region here, e.g., us-east-1)
}

# AWS Security Group Resource
# This resource defines a virtual firewall (security group) that controls inbound and outbound traffic
# for your EC2 instances. It's configured to allow necessary access for RDP and SSH.
resource "aws_security_group" "common_server_sg" {
  name        = "your-project-common-server-access-sg"
  description = "Allow rdp and ssh traffic for servers"

  ingress {
    from_port   = 3389
    to_port     = 3389
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

  tags = {
    Name = "your-project-Common-Server-SG"
  }
}

# AWS Key Pair Data Source
data "aws_key_pair" "server_key" {
  key_name = "ENTER KEY NAME HERE"
}

# AWS EC2 Instance Resource: Windows Server
resource "aws_instance" "windows_server_01" {
  ami           = "ami-02b60b5095d1e5227" # default AMI ID
  instance_type = "t3.medium" # default instance type
  key_name      = data.aws_key_pair.server_key.key_name
  vpc_security_group_ids = [aws_security_group.common_server_sg.id]
  user_data = <<-EOF
              <powershell>
              # Add any PowerShell commands for initial setup here.
              </powershell>
              EOF
  tags = {
    Name        = "your-project-WinServer01"
    Environment = "ACG-Sandbox"
    OS          = "Windows"
  }
}

# AWS EC2 Instance Resource: Ubuntu Server
resource "aws_instance" "ubuntu_server_01" {
  ami           = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"
  key_name      = data.aws_key_pair.server_key.key_name
  vpc_security_group_ids = [aws_security_group.common_server_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt upgrade -y
              EOF
  tags = {
    Name        = "your-project-UbuntuServer01"
    Environment = "ACG-Sandbox"
    OS          = "Ubuntu"
  }
}

# AWS EC2 Instance Resource: Amazon Linux 2023 (AL23) Server
resource "aws_instance" "al23_server_01" {
  ami           = "ami-09e6f87a47903347c"
  instance_type = "t2.micro"
  key_name      = data.aws_key_pair.server_key.key_name
  vpc_security_group_ids = [aws_security_group.common_server_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              sudo dnf update -y
              sudo dnf upgrade -y
              EOF
  tags = {
    Name        = "your-project-AL23Server01"
    Environment = "ACG-Sandbox"
    OS          = "AmazonLinux23"
  }
}

# Output Block: Windows Server Public IP
output "windows_server_public_ip" {
  description = "windows public IP address"
  value       = aws_instance.windows_server_01.public_ip
}

# Output Block: Ubuntu Server Public IP
output "ubuntu_server_public_ip" {
  description = "ubuntu public IP address"
  value       = aws_instance.ubuntu_server_01.public_ip
}

# Output Block: AL23 Server Public IP
output "al23_server_public_ip" {
  description = "AL23 public IP address"
  value       = aws_instance.al23_server_01.public_ip
}
