data "terraform_remote_state" "remote-state" {
  backend = "s3"
  config {
    bucket = "${var.dns_zone_name}-concourse-state"
    key = "terraform.tfstate"
    region = "eu-west-1"
  }
}