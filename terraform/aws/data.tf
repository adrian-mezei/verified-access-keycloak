data "aws_availability_zones" "azs" {
  state = "available"
  filter {
    name = "opt-in-status"
    values = [
      "opt-in-not-required"]
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true


  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["137112412989"] // AWS
}