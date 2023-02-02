provider "aws" {
  region = var.region
}

# Create Instance

resource "aws_instance" "app_server" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = ["${aws_security_group.moiz_web_sg.id}"]

  tags = {
    Name = "VarTest"
  }
}



# Create VPC

resource "aws_vpc" "test_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "MoizVPC"
  }
}

# Create Subnets

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = var.pub_subnet
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = var.prt_subnet
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Private Subnet"
  }
}


# Create Internetgateway

resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "Some Internet Gateway"
  }
}





# Create Security Group

resource "aws_security_group" "moiz_web_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.test_vpc.id

  dynamic "ingress" {
    for_each = var.i_ports
    iterator = i_port
    content {
      description = "SSH HTTP, and HTTPS"
      from_port   = i_port.value
      to_port     = i_port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
