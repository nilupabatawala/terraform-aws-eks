resource "aws_vpc" "eks-vpc" {

  cidr_block = var.aws_vpc

  tags = {
    Name = "aws-eks-vpc"
  }

}

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    Name = "Internet Gateway"
  }

}


resource "aws_subnet" "private_subnet1" {

  vpc_id            = aws_vpc.eks-vpc.id
  cidr_block        = var.private_subnet1
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    "Name"                            = "private-subnet-1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }

}

resource "aws_subnet" "private_subnet2" {

  vpc_id            = aws_vpc.eks-vpc.id
  cidr_block        = var.private_subnet2
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    "Name"                            = "private-subnet-2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }

}


resource "aws_subnet" "public_subnet1" {

  vpc_id            = aws_vpc.eks-vpc.id
  cidr_block        = var.public_subnet1
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    "Name"                       = "public-subnet-1"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}

resource "aws_subnet" "public_subnet2" {

  vpc_id            = aws_vpc.eks-vpc.id
  cidr_block        = var.public_subnet2
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    "Name"                       = "public-subnet-2"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}


resource "aws_eip" "nat" {

  tags = {
    "Name" = "eip-nat"
  }

}

resource "aws_nat_gateway" "natgw" {

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = {
    Name = "nat gw"
  }

  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }


  tags = {
    Name = "private"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "private_subnet1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public.id
}