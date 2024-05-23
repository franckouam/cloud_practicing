#Configure aws provider
provider "aws" {
  region = "us-east-1"
}

#Create a subnet
resource "aws_subnet" "this" {
  vpc_id     = "vpc-0f2cdbc6a33637627"
  cidr_block = "15.9.97.0/25"

  tags = {
    Name = "kofra-public-subnet"
  }
}
