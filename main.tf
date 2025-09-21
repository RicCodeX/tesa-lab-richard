terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws   = { source = "hashicorp/aws", version = "~> 5.0" }
    tls   = { source = "hashicorp/tls", version = "~> 4.0" }
    local = { source = "hashicorp/local", version = "~> 2.4" }
  }
}

provider "aws" {
  region = var.region
}

# Use existing VPC and IGW by ID (given by you)
data "aws_vpc" "richard_vpc" {
  id = var.vpc_id
}

data "aws_internet_gateway" "richard_igw" {
  internet_gateway_id = var.igw_id
}

# Your public subnet (auto-assign public IP)
resource "aws_subnet" "richard_subnet" {
  vpc_id                  = data.aws_vpc.richard_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.name_prefix}-subnet", Owner = var.name_prefix }
}

# Route to internet via the existing IGW
resource "aws_route_table" "richard_public_rt" {
  vpc_id = data.aws_vpc.richard_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.richard_igw.id
  }
  tags = { Name = "${var.name_prefix}-public-rt", Owner = var.name_prefix }
}

resource "aws_route_table_association" "richard_public_assoc" {
  subnet_id      = aws_subnet.richard_subnet.id
  route_table_id = aws_route_table.richard_public_rt.id
}

# SG: SSH from your IP + app on TCP 8000 (open)
resource "aws_security_group" "richard_sg" {
  name        = "${var.name_prefix}-sg"
  description = "Allow SSH from my IP and TCP 8000 to the world"
  vpc_id      = data.aws_vpc.richard_vpc.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "App traffic on 8000"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-sg", Owner = var.name_prefix }
}

# Latest Ubuntu 22.04 LTS (Canonical)

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Generate SSH key pair
resource "tls_private_key" "richard" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "richard" {
  key_name   = "${var.name_prefix}-key"
  public_key = tls_private_key.richard.public_key_openssh
  tags       = { Name = "${var.name_prefix}-key", Owner = var.name_prefix }
}

# Save private key locally
resource "local_file" "richard_pem" {
  filename        = "${path.module}/${var.name_prefix}-key.pem"
  content         = tls_private_key.richard.private_key_pem
  file_permission = "0600"
}

# EC2 instance with public IP + user_data (Flask on :8000)
resource "aws_instance" "richard_ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.richard_subnet.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.richard.key_name
  vpc_security_group_ids      = [aws_security_group.richard_sg.id]
  user_data                   = file("${path.module}/user_data.sh")

  tags = { Name = "${var.name_prefix}-ec2", Owner = var.name_prefix }
}
