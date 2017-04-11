data "terraform_remote_state" "remote-state" {
  backend = "s3"
  config {
    bucket = "${aws_s3_bucket.state-bucket.bucket}"
    key = "terraform.tfstate"
    region = "eu-west-1"
  }
}