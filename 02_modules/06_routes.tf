resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = {
    Name = "${var.env}-private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "${var.env}-public"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.aws_subnet.private)

  subnet_id = aws_subnet.private[count.index]
  route_table_id = aws_route_table.private.id 
}

resource "aws_route_table_association" "public" {
  count = length(var.aws_subnet.public)

  subnet_id = aws_subnet.pulic[count.index]
  route_table_id = aws_route_table.public.id
}