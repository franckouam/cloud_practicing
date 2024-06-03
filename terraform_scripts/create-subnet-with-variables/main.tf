#Configure aws provider
provider "aws" {
  region = var.region
}

#Create a subnet
resource "aws_subnet" "this" {
  vpc_id     = var.vpc_id
  cidr_block = var.cidr_block

  tags = {
    Name = var.subnet_name
  }
}
