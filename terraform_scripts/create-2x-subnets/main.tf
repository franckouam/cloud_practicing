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

  tags = {
    Name = var.subnet_public
  }
}

#Create a subnet
resource "aws_subnet" "private" {
  vpc_id     = data.aws_vpc.this.id
  cidr_block = var.cidr_block_private

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
