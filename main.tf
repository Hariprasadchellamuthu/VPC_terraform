provider "aws" {
  region = "us-east-1" # Change to your desired region
}

variable "vpc_cidr_block" {
  type        = string
  default = "10.0.0.0/16"
}
variable "public_subnet_count" {
  type        = number
  description = "Number of public subnets"
  default     = 2
}

variable "private_subnet_count" {
  type        = number
  description = "Number of private subnets"
  default     = 2
}


variable "public_subnet_cidr_blocks" {
  type        = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "private_subnet_cidr_blocks" {
   type        = list(string)
   default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]  
}
variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
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
 count             = length(var.public_subnet_cidrs)
 vpc_id            = aws_vpc.main.id
 cidr_block        = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}

resource "aws_subnet" "private_subnets" {
 count             = length(var.private_subnet_cidrs)
 vpc_id            = aws_vpc.main.id
 cidr_block        = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}
