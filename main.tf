provider "aws" {
  region = var.region
}

# Create Instance

# resource "aws_instance" "app_server" {
#   ami             = var.image_id
#   instance_type   = var.instance_type
#   subnet_id       = aws_subnet.public_subnet.id
#   security_groups = ["${aws_security_group.moiz_web_sg.id}"]

#   tags = {
#     Name = "VarTest"
#   }
# }



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
  availability_zone = "eu-west-2b"

  tags = {
    Name = "Private Subnet"
  }
}


# Create Internetgateway

resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "Internet Gateway"
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





# Route Tables

resource "aws_route_table" "moiz_public_rt" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.test_igw.id
  }

  tags = {
    Name = "Test Public Route Table"
  }
}


resource "aws_route_table_association" "public_rt" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.moiz_public_rt.id
}

resource "aws_route_table_association" "public_rt2" {
  route_table_id = aws_route_table.moiz_public_rt.id
  subnet_id      = aws_subnet.private_subnet.id
}



#Creating RDS

# resource "aws_db_instance" "test" {
#   allocated_storage    = 20
#   identifier           = "test123"
#   storage_type         = "gp2"
#   engine               = "mysql"
#   engine_version       = "5.7"
#   instance_class       = "db.t2.micro"
#   username             = "admin"
#   password             = "Admin123"
#   db_subnet_group_name = aws_db_subnet_group.test-db-subnet.name
#   #final_snapshot_identifier= false
#   # parameter_group_name = "default.mysql5.7"
# }

#Creating RDS Subnet Group

# resource "aws_db_subnet_group" "test-db-subnet" {
#   name       = "db subnet group"
#   subnet_ids = ["${aws_subnet.public_subnet.id}", "${aws_subnet.private_subnet.id}"]
# }




# Create Load Balancer


resource "aws_alb" "alb" {
  name            = "moiz-terraform-alb"
  security_groups = ["${aws_security_group.moiz_web_sg.id}"]
  subnets         = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
  tags = {
    Name = "moiz-terraform-alb"
  }
}

# Create Target Groups


resource "aws_alb_target_group" "group" {
  name     = "moiz-terraform-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.test_vpc.id
  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/"
    port = 80
  }
}

# Create Listeners

resource "aws_alb_listener" "moiz_listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.group.arn
    type             = "forward"
  }
}


# Create Listeners HTTP

resource "aws_alb_listener" "listener_https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:eu-west-2:255950308419:certificate/9b879609-0a1e-41bd-b2d6-55df42e54de0"
  default_action {
    target_group_arn = aws_alb_target_group.group.arn
    type             = "forward"
  }
}
