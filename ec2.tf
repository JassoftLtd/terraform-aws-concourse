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

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.eu-west-1a-public.id}"
  user_data = "${file("cloud-config/concourse-web.yaml")}"
  associate_public_ip_address = true

  tags {
    Name = "Concoourse-Web"
  }
}