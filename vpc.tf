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
resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "eu-west-1a"

  tags {
    Name = "Concourse Public Subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "Concourse Public Subnet"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_eip" "nat_eip" {
  vpc   = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.public.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "private-a" {
  vpc_id            = "${aws_vpc.default.id}"

  cidr_block        = "${var.private_subnet_cidr}"
  availability_zone = "${var.availability_zones[0]}"

  tags {
    Name = "Concourse Private Subnet-a"
  }
}
resource "aws_subnet" "private-b" {
  vpc_id            = "${aws_vpc.default.id}"

  cidr_block        = "${var.private_subnet_cidr}"
  availability_zone = "${var.availability_zones[1]}"

  tags {
    Name = "Concourse Private Subnet-b"
  }
}
resource "aws_subnet" "private-c" {
  vpc_id            = "${aws_vpc.default.id}"

  cidr_block        = "${var.private_subnet_cidr}"
  availability_zone = "${var.availability_zones[2]}"

  tags {
    Name = "Concourse Private Subnet-c"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "Concourse Private Subnet"
  }
}

resource "aws_route" "private_nat_gateway_route" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat_gw.id}"
}

resource "aws_route_table_association" "private-a" {
  subnet_id = "${aws_subnet.private-a.id}"
  route_table_id = "${aws_route_table.private.id}"
}
resource "aws_route_table_association" "private-b" {
  subnet_id = "${aws_subnet.private-b.id}"
  route_table_id = "${aws_route_table.private.id}"
}
resource "aws_route_table_association" "private-c" {
  subnet_id = "${aws_subnet.private-c.id}"
  route_table_id = "${aws_route_table.private.id}"
}

/*
  Database Subnet Group
*/
resource "aws_db_subnet_group" "concourse_rds_subnet_group" {
  name        = "concourse_rds_subnet_group"
  description = "Database subnet group"
  subnet_ids  = ["${aws_subnet.public.id}", "${aws_subnet.private-a.id}", "${aws_subnet.private-b.id}", "${aws_subnet.private-c.id}"]

}