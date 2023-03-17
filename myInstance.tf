#Variables
variable "myaccess_key" {
  default= "AKIAYP6BPB6A5WYJPMRU"
  }
variable "mysecret_key" {
   default= "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"
}
variable "region" { default = "us-east-2"}
 
#Provider

provider "aws" {


    access_key = "${var.myaccess_key}"
    secret_key = "${var.mysecret_key}"
    region = "${var.region}"
 
}



#provider "aws" {
 # profile = "default"
 # region  = "us-east-2"
# }

resource "aws_vpc" "some_custom_vpc" {
  cidr_block = "192.168.0.0/22"

  tags = {
    Name = "Some Custom VPC"
  }
}

resource "aws_subnet" "some_public_subnet" {
  vpc_id            = aws_vpc.some_custom_vpc.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "Some Public Subnet"
  }
}

resource "aws_subnet" "some_private_subnet" {
  vpc_id            = aws_vpc.some_custom_vpc.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "Some Private Subnet"
  }
}

resource "aws_internet_gateway" "some_ig" {
  vpc_id = aws_vpc.some_custom_vpc.id

  tags = {
    Name = "Some Internet Gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.some_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.some_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.some_ig.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.some_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.some_custom_vpc.id

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
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_instance" {
  ami           = "ami-03a5def6b0190cef7"
  instance_type = "t2.micro"
  key_name      = "new_knb_key"
  count = 3 

  subnet_id                   = aws_subnet.some_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  
  tags = {
    "Name" : "myvertex"
  }
}
