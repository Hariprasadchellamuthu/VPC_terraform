provider "aws" {
  region = "us-east-1" # Change to your desired region
}

variable "vpc_cidr_block" {
  type        = string
  default = "10.0.0.0/16"
}
variable "public_subnet_count" {
  type        = number
  default = 2
}
variable "private_subnet_count" {
  type        = number
  default = 2
}
variable "public_subnet_cidr_blocks" {
  type        = string
  default = "10.0.1.0/24"
}
variable "private_subnet_cidr_blocks" {
   type        = string
   default = "10.0.2.0/24"   
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "VPC_Pro"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_subnet" "public_subnets" {
  count = var.public_subnet_count
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.public_subnet_cidr_blocks
  availability_zone = "us-east-1a" # Change to your desired availability zone
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnets" {
  count = var.private_subnet_count
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.private_subnet_cidr_blocks
  availability_zone = "us-east-1b" # Change to your desired availability zone
}
