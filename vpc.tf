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
    Name = "concourse-public-subnet"
  }
}

resource "aws_route_table" "eu-west-1a-public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "concourse-public-subnet"
  }
}

resource "aws_route_table_association" "eu-west-1a-public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.eu-west-1a-public.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "eu-west-1b"

  tags {
    Name = "concourse-private-subnet"
  }
}

resource "aws_route_table" "eu-west-1a-private" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "concourse-private-subnet"
  }
}

resource "aws_route_table_association" "eu-west-1a-private" {
  subnet_id = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.eu-west-1a-private.id}"
}

resource "aws_db_subnet_group" "concourse_rds_subnet_group" {
  name        = "concourse_rds_subnet_group"
  description = "Database subnet group"
  subnet_ids  = ["${aws_subnet.public.id}", "${aws_subnet.private.id}"]

}