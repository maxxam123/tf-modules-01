resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    {Name = "${var.env}-private-${var.azs[count.index]}"},
    var.private_subnets_tags
  )
}

