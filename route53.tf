resource "aws_route53_record" "concourse" {
  zone_id = "${var.dns_zone_id}"
  name    = "concourse.${var.dns_zone_name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_instance.concourse_web.public_dns}"]
}
