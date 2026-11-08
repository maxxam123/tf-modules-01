resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "spoke-${var.env}-igw-${format("%02d", count.index + 1)}"
    NetworkTier = "spoke-igw"
  }
}