terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Busca la imagen mas reciente de Ubuntu 24.04 (solo consulta, no crea nada)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# 1. El candado: sube nuestra llave publica a AWS
resource "aws_key_pair" "llave" {
  key_name   = "fase3-vault"
  public_key = file("~/.ssh/fase3-vault.pub")
}

# 2. El portero: puertos 22 (SSH) y 8200 (Vault)
resource "aws_security_group" "vault" {
  name        = "fase3-vault-sg"
  description = "SSH y Vault"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Vault"
    from_port   = 8200
    to_port     = 8200
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

# 3. La computadora: Ubuntu t3.micro con el candado y el portero
resource "aws_instance" "vault" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.llave.key_name
  vpc_security_group_ids = [aws_security_group.vault.id]

  tags = {
    Name = "fase3-vault"
  }
}

output "ip_publica" {
  value = aws_instance.vault.public_ip
}
