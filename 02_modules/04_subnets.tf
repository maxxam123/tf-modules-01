resource "private_subnet" "private" {
  count = length(var.privat_subnets)

  vpc_id = aws_vpc.this.id
  cidr_block = var.privat_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    { Name = "${var.env}-private-${var.azs[count.index]}"},
    var.privat_subnets_tags
  )
}

resource "aws_subnet" "pulic" {
  count = length(var.public_subnets)

  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    { Name = "${var.env}-puclic-${var.azs[count.index]}"},
    var.public_subnets_tags
  )
}