data "aws_route53_zone" "dns_zone" {
  name = "${var.dns_zone_name}"
}

resource "aws_route53_record" "concourse" {
  zone_id = "${data.aws_route53_zone.dns_zone.id}"
  name    = "concourse.${var.dns_zone_name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_instance.concourse_web.public_dns}"]
}
