#Configure AWS provider
provider "aws" {
  region = var.region
}

#Reading vpc resource
data "aws_vpc" "this" {
  filter {
    name = "tag:Name"
    values = var.vpc_name
  }
}

#Read a subnet resource
data "aws_subnet" "public" {
  filter {
    name = "tag:Name"
    values = var.subnet_name
  }
}

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
