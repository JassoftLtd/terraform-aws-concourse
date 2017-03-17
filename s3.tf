resource "aws_s3_bucket" "keys-bucket" {
  bucket = "concourse-keys"
  acl = "private"
  force_destroy = true
}