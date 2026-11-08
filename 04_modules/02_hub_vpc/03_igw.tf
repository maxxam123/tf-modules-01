resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.hub.id

  tags = {
    Name = "hub-${var.env}-igw-${format("%02d", count.index + 1)}"
    NetworkTier = "hub-igw"
  }
}