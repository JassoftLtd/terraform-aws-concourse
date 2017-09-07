resource "aws_security_group" "concourse_web_security_group" {
  name        = "concourse_web_security_group"
  description = "Allow access from the internet"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = "${var.whitelist_ips}"
  }

  ingress {
    from_port   = "2222"
    to_port     = "2222"
    protocol    = "tcp"
    cidr_blocks = "${var.public_subnet_cidr}"
  }

  ingress {
    from_port   = "2222"
    to_port     = "2222"
    protocol    = "tcp"
    cidr_blocks = "${var.private_subnet_cidr}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "concourse_worker_security_group" {
  name        = "concourse_worker_security_group"
  description = "Allow access"
  vpc_id      = "${aws_vpc.default.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "concourse_db_security_group" {
  name        = "concourse_db_security_group"
  description = "Allow access from the subnet"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = "5432"
    to_port     = "5432"
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }
}
