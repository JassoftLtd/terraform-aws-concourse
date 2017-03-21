output "concourse_web_url" {
  value = "http://${aws_instance.concourse_web.public_dns}:8080"
}
