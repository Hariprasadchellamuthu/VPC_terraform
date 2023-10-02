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
  description = "Number of public subnets"
  default     = 2
}

variable "public_routetable_count" {
  type        = number
  description = "Number of public route table"
  default     = 1
}

variable "private_routetable_count" {
  type        = number
  description = "Number of private route table"
  default     = 1
}


variable "public_subnet_cidrs" {
  type        = list(string)
  default = ["10.0.1.0/24"]
}
variable "private_subnet_cidrs" {
   type        = list(string)
   default = ["10.0.4.0/24"]  
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
 count             = var.public_subnet_count
 vpc_id            = aws_vpc.my_vpc.id
 cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index) 
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}

resource "aws_subnet" "private_subnets" {
 count             = var.private_subnet_count
 vpc_id            = aws_vpc.my_vpc.id
 cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index + 100)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}

# Create a route table for the public subnets
resource "aws_route_table" "public_route_table" {
  count  = var.public_routetable_count
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "Public Subnet Route Table ${count.index + 1}"
  }
}


# Associate each public subnet with its route table
resource "aws_route_table_association" "public_subnet_association" {
  count        = var.public_subnet_count
  subnet_id    = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table[count.index].id
}

# Create a NAT gateway for each public subnet
resource "aws_nat_gateway" "my_nat_gateway" {
  count         = var.private_subnet_count
  allocation_id = aws_eip.my_eip[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
}

# Create an Elastic IP for each NAT gateway
resource "aws_eip" "my_eip" {
  count = var.public_subnet_count
}

# Create a route table for the private subnets (for routing through the NAT gateways)
resource "aws_route_table" "private_route_table" {
  count  = var.private_routetable_count
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Private Subnet Route Table ${count.index + 1}"
  }
}

# Add a route to each private subnet route table to route traffic through the corresponding NAT gateway
resource "aws_route" "private_route" {
  count                  = var.private_subnet_count
  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat_gateway[count.index].id
}

# Associate each private subnet with its route table
resource "aws_route_table_association" "private_subnet_association" {
  count        = var.private_subnet_count
  subnet_id    = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}
