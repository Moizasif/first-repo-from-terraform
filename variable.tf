variable "region" { default = "eu-west-2" }
variable "ami" { default = "ami-0be62737f5a0a1f3a" }
variable "instance_type" { default = "t2.micro" }
variable "vpc_cidr_block" { default = "10.0.0.0/16" }
variable "pub_subnet" { default = "10.0.1.0/24" }
variable "prt_subnet" { default = "10.0.2.0/24" }
variable "i_ports" { default = [22, 80, 443] }
