resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "terraform-aws-vpc"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

/*
  Public Subnet
*/
resource "aws_subnet" "eu-west-1a-public" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "eu-west-1a"

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table" "eu-west-1a-public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table_association" "eu-west-1a-public" {
  subnet_id = "${aws_subnet.eu-west-1a-public.id}"
  route_table_id = "${aws_route_table.eu-west-1a-public.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "eu-west-1a-private" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "eu-west-1a"

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table" "eu-west-1a-private" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table_association" "eu-west-1a-private" {
  subnet_id = "${aws_subnet.eu-west-1a-private.id}"
  route_table_id = "${aws_route_table.eu-west-1a-private.id}"
}