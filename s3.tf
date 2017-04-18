resource "aws_s3_bucket" "keys-bucket" {
  bucket = "concourse.${var.dns_zone_name}concourse-keys"
  acl = "private"
  force_destroy = true
}

resource "aws_s3_bucket" "state-bucket" {
  bucket = "concourse.${var.dns_zone_name}concourse-state"
  acl = "private"
}