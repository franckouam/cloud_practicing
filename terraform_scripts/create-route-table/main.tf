#Configure aws provider
provider "aws" {
  region = var.region
}

#Read vpc resource 
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = var.vpc_name
  }
}

#Create a subnet
resource "aws_subnet" "public" {
  vpc_id     = data.aws_vpc.this.id
  cidr_block = var.cidr_block_public
  availability_zone = "${var.region}a"

  tags = {
    Name = var.subnet_public
  }
}

#Create a subnet
resource "aws_subnet" "private" {
  vpc_id     = data.aws_vpc.this.id
  cidr_block = var.cidr_block_private
  availability_zone = "${var.region}b"
  tags = {
    Name = var.subnet_private
  }
}


#Capture vpc_id in output variable
output "vpc_id" {
  value = data.aws_vpc.this.id
}

#Capture vpc_cidr_block in output variable
output "vpc_cidr_block" {
  value = data.aws_vpc.this.cidr_block
}

#Creating an internet gateway
resource "aws_internet_gateway" "kofra_gw" {
  vpc_id = data.aws_vpc.this.id
  tags = {
    Name = "kofra-internet-gw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = data.aws_vpc.this.id
  route {
    cidr_block = var.cidr_block
    gateway_id = aws_internet_gateway.kofra_gw.id
  }
  tags = {
    Name = "kofra-route-table"
  }

}

resource "aws_route_table_association" "route_association" {
  subnet_id      = data.aws_subnet.public.id
  route_table_id = aws_route_table.route_table.id
}
