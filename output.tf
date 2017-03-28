output "concourse_web_url" {
  value = "http://${aws_route53_record.concourse.fqdn}:8080"
}
