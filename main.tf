provider "aws" {
  region = "ap-south-1"
}

# Generate a new SSH key pair using TLS
resource "tls_private_key" "web_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create AWS key pair using the generated public key
resource "aws_key_pair" "web_key" {
  key_name   = "web-key-${random_id.suffix.hex}"
  public_key = tls_private_key.web_key.public_key_openssh
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Security group to allow HTTP (port 80) and SSH (port 22) traffic
resource "aws_security_group" "lab_2" {
  name_prefix = "web_sg_"
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
}

# Provision an EC2 instance
resource "aws_instance" "web_server" {
  ami           = "ami-01816d07b1128cd2d"  # Replace with a valid AMI ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.web_key.key_name
  security_groups = [aws_security_group.lab_2.name]
  
  tags = {
    Name = "WebServer"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Provisioning started!'"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.web_key.private_key_pem
      host        = self.public_ip
      timeout     = "5m"
    }
  }
}

# Output the private key to be used later in GitHub Actions
output "private_key" {
  value     = tls_private_key.web_key.private_key_pem
  sensitive = true
}

# Output the public key (if needed)
output "public_key" {
  value = tls_private_key.web_key.public_key_openssh
}
