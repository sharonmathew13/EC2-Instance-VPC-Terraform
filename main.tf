terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    "Name" = "vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  cidr_block = "10.0.1.0/24"
  tags = {
    "Name" = "public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    "Name" = "private_subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "Internet Gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    "Name" = "Public Route Table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}



resource "aws_instance" "jenkins" {
  ami                    = "ami-02f3f602d23f1659d" # Amazon Linux 2
  subnet_id              = aws_subnet.public_subnet.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.jenkin-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo wget -O /etc/yum.repos.d/jenkins.repo  https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              sudo yum upgrade
              sudo yum install java-11-amazon-corretto-headless -y
              sudo yum install java-11-amazon-corretto -y 
              sudo yum install java-11-amazon-corretto-devel -y
              sudo yum install jenkins -y 
               sudo systemctl enable jenkins
                sudo systemctl start jenkins
              EOF
}

resource "aws_security_group" "jenkin-sg" {
  name_prefix = "jenkins-"
  vpc_id      = aws_vpc.vpc.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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


resource "aws_s3_bucket" "mybicket" {
  bucket = "jenkins-sharon-1308"
}























































