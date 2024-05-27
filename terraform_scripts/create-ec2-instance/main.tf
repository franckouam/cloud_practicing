#Configure AWS provider
provider "aws" {
  region = var.region
}

data "aws_security_group" "sg" {
  filter {
    name = "tag:Name"
    values = var.security_group_name
  }
}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["aws-marketplace"]
  filter {
    name = "name"
    values = var.image_name
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["ebs"]
  }

}

resource "aws_instance" "terraform_instance" {
  ami = data.aws_ami.ami.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = data.aws_security_group.sg.id
  associate_public_ip_address = true
  source_dest_check = false
  tags = {
    Name = var.instance_name
  }
}
