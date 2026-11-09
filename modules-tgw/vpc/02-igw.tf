resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "hub-${var.env}-igw"
    NetworkTier = "hub-igw"
  }
}