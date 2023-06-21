# Create a VPC
resource "aws_vpc" "aminat-VPC" {
  cidr_block = "10.0.0.0/16"
}

# Create subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.aminat-VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.aminat-VPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "aminat_igw" {
  vpc_id = aws_vpc.aminat-VPC.id

  tags = {
    Name = "aminat_igw"
  }
}

# Create route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.aminat-VPC.id

  route { 
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.aminat_igw.id}"
  }

  tags = {
    Name = "public_rt"
  }
}

# Associate subnet with route table 
resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


# Create security group
resource "aws_security_group" "aminat_sg" {
  name        = "aminat_sg"
  vpc_id      = aws_vpc.aminat-VPC.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "aminat_sg"
  }
}

# Create EC2 instance
resource "aws_instance" "aminatEC2" {
  ami                    = "ami-022e1a32d3f742bd8"  
  instance_type          = "t2.micro"                
  key_name               = "mykey"             
  subnet_id              = aws_subnet.public_subnet.id 
  vpc_security_group_ids = [aws_security_group.aminat_sg.id]  
tags = {
    Name = "aminatEC2"
  }
}