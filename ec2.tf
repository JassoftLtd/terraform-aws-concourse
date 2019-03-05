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
    database_address          = "${aws_db_instance.concourse-db.address}"
    database_port             = "${aws_db_instance.concourse-db.port}"
    database_username         = "${aws_db_instance.concourse-db.username}"
    database_password         = "${aws_db_instance.concourse-db.password}"
    database_identifier       = "${aws_db_instance.concourse-db.name}"
    keys_bucket               = "${aws_s3_bucket.keys-bucket.bucket}"
    github_auth_client_id     = "${var.github_auth_client_id}"
    github_auth_client_secret = "${var.github_auth_client_secret}"
    github_auth_team          = "${var.github_auth_team}"
    external-url              = "http://concourse.${var.dns_zone_name}/"
    concourse_version         = "${var.concourse_version}"
  }
}

data "template_file" "concourse_worker_init" {
  template = "${file("cloud-config/concourse-worker.tpl")}"

  vars {
    tsa_host            = "${aws_instance.concourse_web.private_ip}"
    tsa_port            = "2222"
    keys_bucket         = "${aws_s3_bucket.keys-bucket.bucket}"
    concourse_version   = "${var.concourse_version}"
    baggageclaim_driver = "naive"
  }
}

resource "aws_instance" "concourse_web" {
  ami                         = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "${var.concourse_web_instance_type}"
  subnet_id                   = "${element(aws_subnet.public.*.id, 0)}"
  user_data                   = "${data.template_file.concourse_web_init.rendered}"
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.concourse_profile.id}"
  vpc_security_group_ids      = ["${aws_security_group.concourse_web_security_group.id}"]
  key_name                    = "${var.key_name}"
  monitoring                  = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 100
  }

  tags {
    Name = "Concourse-Web"
  }
}

resource "aws_spot_fleet_request" "concourse_workers" {
  iam_fleet_role                      = "${aws_iam_role.concourse_worker_role.arn}"
  spot_price                          = "${var.concourse_workers_spot_request_max_price}"
  target_capacity                     = "${var.concourse_workers_min_instances}"
  valid_until                         = "2019-11-04T20:44:20Z"
  replace_unhealthy_instances         = true
  terminate_instances_with_expiration = true

  launch_specification {
    instance_type               = "${var.concourse_workers_instance_type}"
    ami                         = "${data.aws_ami.amazon_linux.id}"
    subnet_id                   = "${var.private_workers == false ? element(aws_subnet.public.*.id, 0) : element(aws_subnet.private.*.id, 0)}"
    associate_public_ip_address = "${var.private_workers == false}"
    vpc_security_group_ids      = ["${aws_security_group.concourse_worker_security_group.id}"]
    user_data                   = "${data.template_file.concourse_worker_init.rendered}"
    iam_instance_profile        = "${aws_iam_instance_profile.concourse_profile.id}"
    key_name                    = "${var.key_name}"
    monitoring                  = true

    root_block_device {
      volume_type = "gp2"
      volume_size = "${var.concourse_workers_volume_size}"
    }

    tags {
      Name = "Concourse-Worker"
    }
  }

  launch_specification {
    instance_type               = "${var.concourse_workers_instance_type}"
    ami                         = "${data.aws_ami.amazon_linux.id}"
    subnet_id                   = "${var.private_workers == false ? element(aws_subnet.public.*.id, 1) : element(aws_subnet.private.*.id, 1)}"
    associate_public_ip_address = "${var.private_workers == false}"
    vpc_security_group_ids      = ["${aws_security_group.concourse_worker_security_group.id}"]
    user_data                   = "${data.template_file.concourse_worker_init.rendered}"
    iam_instance_profile        = "${aws_iam_instance_profile.concourse_profile.id}"
    key_name                    = "${var.key_name}"
    monitoring                  = true

    root_block_device {
      volume_type = "gp2"
      volume_size = "${var.concourse_workers_volume_size}"
    }

    tags {
      Name = "Concourse-Worker"
    }
  }

  launch_specification {
    instance_type               = "${var.concourse_workers_instance_type}"
    ami                         = "${data.aws_ami.amazon_linux.id}"
    subnet_id                   = "${var.private_workers == false ? element(aws_subnet.public.*.id, 2) : element(aws_subnet.private.*.id, 2)}"
    associate_public_ip_address = "${var.private_workers == false}"
    vpc_security_group_ids      = ["${aws_security_group.concourse_worker_security_group.id}"]
    user_data                   = "${data.template_file.concourse_worker_init.rendered}"
    iam_instance_profile        = "${aws_iam_instance_profile.concourse_profile.id}"
    key_name                    = "${var.key_name}"
    monitoring                  = true

    root_block_device {
      volume_type = "gp2"
      volume_size = "${var.concourse_workers_volume_size}"
    }

    tags {
      Name = "Concourse-Worker"
    }
  }
}
