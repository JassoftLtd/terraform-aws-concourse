data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-2016.09.1.20170119-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "concourse_web_init" {
  template = "${file("cloud-config/concourse-web.tpl")}"

  vars {
    database_address = "${aws_db_instance.concourse-db.address}"
    database_port = "${aws_db_instance.concourse-db.port}"
    database_username = "${aws_db_instance.concourse-db.username}"
    database_password = "${aws_db_instance.concourse-db.password}"
    database_identifier = "${aws_db_instance.concourse-db.name}"
  }
}

resource "aws_instance" "concourse_web" {
  ami           = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public.id}"
  private_ip = "10.0.0.4"
  user_data = "${data.template_file.concourse_web_init.rendered}"
  associate_public_ip_address = true
  key_name = "jonshaw"

  vpc_security_group_ids = ["${aws_security_group.concourse_web_security_group.id}"]

  tags {
    Name = "Concoourse-Web"
  }
}