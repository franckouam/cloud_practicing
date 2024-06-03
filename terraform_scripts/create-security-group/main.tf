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

#Creating a routing table
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

#Adding an association for the created routing table
resource "aws_route_table_association" "route_association" {
  subnet_id      = data.aws_subnet.public.id
  route_table_id = aws_route_table.route_table.id
}

#Creating a security group
resource "aws_security_group" "allow_ssh" {
  name        = "kofra-ssh-security-group"
  description = "Allow SSH inbound  and outbound traffic"
  vpc_id      = data.aws_vpc.this.id

  tags = {
    Name = "kofra_allow_ssh"
  }
}

#Adding rules for the incoming traffic
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_in" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = data.aws_vpc.this.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#Adding rules for the outgoing traffic
resource "aws_vpc_security_group_egress_rule" "allow_ssh_out" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  ip_protocol       = "-1"
  to_port           = -1
}
