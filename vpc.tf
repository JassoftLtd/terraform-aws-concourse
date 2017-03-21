resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "concourse-ci-vpc"
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
    Name = "Concourse Public Subnet"
  }
}

resource "aws_route_table" "eu-west-1a-public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "Concourse Public Subnet"
  }
}

resource "aws_route_table_association" "eu-west-1a-public" {
  subnet_id = "${aws_subnet.eu-west-1a-public.id}"
  route_table_id = "${aws_route_table.eu-west-1a-public.id}"
}

resource "aws_eip" "nat_eip" {
  vpc   = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.eu-west-1a-public.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "eu-west-1a-private" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "eu-west-1b"

  tags {
    Name = "Concourse Private Subnet"
  }
}

resource "aws_route_table" "eu-west-1a-private" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "Concourse Private Subnet"
  }
}

resource "aws_route" "private_nat_gateway_route" {
  route_table_id         = "${aws_route_table.eu-west-1a-private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat_gw.id}"
}

resource "aws_route_table_association" "eu-west-1a-private" {
  subnet_id = "${aws_subnet.eu-west-1a-private.id}"
  route_table_id = "${aws_route_table.eu-west-1a-private.id}"
}

/*
  Database Subnet Group
*/
resource "aws_db_subnet_group" "concourse_rds_subnet_group" {
  name        = "concourse_rds_subnet_group"
  description = "Database subnet group"
  subnet_ids  = ["${aws_subnet.eu-west-1a-public.id}", "${aws_subnet.eu-west-1a-private.id}"]

}