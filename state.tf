data "terraform_remote_state" "remote-state" {
  backend = "s3"

  config {
    bucket = "concourse.jassoft.co.uk.concourse-state"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}
