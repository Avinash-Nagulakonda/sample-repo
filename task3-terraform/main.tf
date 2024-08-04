provider "aws" {
region = "ap-south-1"  
access_key= "AKIA4EUFDVESVNRA2AOS"
secret_key= "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"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "My-VPC"
  }
}


resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "My-Subnet"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "My-Internet-Gateway"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public-Route-Table"
  }
}


resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.my_vpc.id
  description = "Allow HTTP and SSH traffic"

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

  tags = {
    Name = "web_security_group"
  }
}


resource "aws_instance" "nginx_instance" {
  ami           = "ami-025b4b7b37b743227" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx -y
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "Nginx-Instance"
    Environment = "Prod"
  }
}

#for detail understanding please visit description.txt
