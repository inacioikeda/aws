resource "aws_vpc" "ds" {
  cidr_block = "10.0.0.0/16"

  tags = map(
    "Name", "ds-eks-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "ds" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.ds.id

  tags = map(
    "Name", "ds-eks-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "ds" {
  vpc_id = aws_vpc.ds.id

  tags = {
    Name = "ds-eks-cluster"
  }
}

resource "aws_route_table" "ds" {
  vpc_id = aws_vpc.ds.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ds.id
  }
}

resource "aws_route_table_association" "ds" {
  count = 2

  subnet_id      = aws_subnet.ds.*.id[count.index]
  route_table_id = aws_route_table.ds.id
}