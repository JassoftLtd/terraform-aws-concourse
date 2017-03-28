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
    keys_bucket = "${aws_s3_bucket.keys-bucket.bucket}"
    basic_auth_username = "${var.basic_auth_username}"
    basic_auth_password = "${var.basic_auth_password}"
    external-url = "http://concourse.${var.dns_zone_name}:8080"
  }
}

data "template_file" "concourse_worker_init" {
  template = "${file("cloud-config/concourse-worker.tpl")}"

  vars {
    tsa_host = "${aws_instance.concourse_web.private_ip}"
    keys_bucket = "${aws_s3_bucket.keys-bucket.bucket}"
  }
}

resource "aws_instance" "concourse_web" {
  ami           = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.eu-west-1a-public.id}"
  private_ip = "10.0.0.5"
  user_data = "${data.template_file.concourse_web_init.rendered}"
  associate_public_ip_address = true
  iam_instance_profile = "${aws_iam_instance_profile.concourse_profile.id}"
  vpc_security_group_ids = ["${aws_security_group.concourse_web_security_group.id}"]
  key_name = "${var.key_name}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 100
  }

  tags {
    Name = "Concoourse-Web"
  }
}

resource "aws_spot_fleet_request" "concourse_workers" {
  iam_fleet_role = "${aws_iam_role.iam_fleet_role.arn}"
  spot_price      = "0.02"
  target_capacity = 1
  valid_until     = "2019-11-04T20:44:20Z"

  launch_specification {
    instance_type     = "m4.large"
    ami               = "${data.aws_ami.amazon_linux.id}"
    subnet_id         = "${aws_subnet.eu-west-1a-private.id}"
    vpc_security_group_ids = ["${aws_security_group.concourse_worker_security_group.id}"]
    user_data         = "${data.template_file.concourse_worker_init.rendered}"
    iam_instance_profile = "${aws_iam_instance_profile.concourse_profile.id}"
    key_name = "${var.key_name}"
    root_block_device {
      volume_type = "gp2"
      volume_size = 100
    }
  }
}