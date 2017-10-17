resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
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
  count  = "${length(var.public_subnet_cidr)}"
  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${var.public_subnet_cidr[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"

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
  count          = "${length(var.public_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_eip" "nat_eip" {
  count = "${var.private_workers == false ? 0 : 1}"
  vpc   = true
}

resource "aws_nat_gateway" "nat_gw" {
  count         = "${var.private_workers == false ? 0 : 1}"
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public.*.id, 0)}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "private" {
  count  = "${length(var.private_subnet_cidr)}"
  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${var.private_subnet_cidr[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"

  tags {
    Name = "Concourse Private Subnet"
  }
}

resource "aws_route_table" "private" {
  count  = "${var.private_workers == false ? 0 : 1}"
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "Concourse Private Subnet"
  }
}

resource "aws_route" "private_nat_gateway_route" {
  count                  = "${var.private_workers == false ? 0 : 1}"
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat_gw.id}"
}

resource "aws_route_table_association" "private-a" {
  count          = "${var.private_workers == false ? 0 : length(var.private_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

/*
  Database Subnet Group
*/
resource "aws_db_subnet_group" "concourse_rds_subnet_group" {
  name        = "concourse_rds_subnet_group"
  description = "Database subnet group"
  subnet_ids  = ["${aws_subnet.public.*.id}", "${aws_subnet.private.*.id}"]
}
