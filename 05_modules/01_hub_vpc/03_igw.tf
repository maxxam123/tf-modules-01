resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.hub.id

  tags = {
    Name = "hub-${var.env}-igw"
    NetworkTier = "hub-igw"
  }
}