provider "aws" {
  region = var.region
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


# Create Instance

resource "aws_instance" "app_server" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "VarTest"
  }
}
