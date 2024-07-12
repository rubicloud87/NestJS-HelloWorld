

##

resource "aws_vpc" "nestjs_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "vpc-nestjs"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.nestjs_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "nestjs_igw" {
  vpc_id = aws_vpc.nestjs_vpc.id
}



resource "aws_route_table" "public_subnet1_rt" {
  vpc_id = aws_vpc.nestjs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nestjs_igw.id
  }
}


resource "aws_route_table_association" "public_subnet1_rt" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_subnet1_rt.id
}

resource "aws_security_group" "nestjs_sg" {
  name        = "NestJS_SG"
  vpc_id      = aws_vpc.nestjs_vpc.id
  description = "Security Group for NestJS Server"
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "3000"
    to_port     = "3000"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "NestJS-SG"
  }
}

resource "aws_instance" "nestjs" {
  ami                         = "ami-0ce38a2f3292a6524"
  instance_type               = "t2.small"
  vpc_security_group_ids         = [aws_security_group.nestjs_sg.id]
  associate_public_ip_address = true
  subnet_id = aws_subnet.public_subnet1.id
}
inline = [
    "git clone https://github.com/rubicloud87/NestJS-HelloWorld.git",
    "sudo apt update",
    "sudo apt install -y nodejs npm",
    "cd nest-hello-world",
    "npm install",
    "npm run start"
  ]

}
