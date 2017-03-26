variable "aws_access_key" {
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
}

variable "aws_region" {
  description = "AWS Region"
  default = "eu-west-1"
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the Private Subnet"
  default = "10.0.1.0/24"
}

variable "key_name" {
  description = "Key pair name"
}

variable "basic_auth_username" {
  description = "Username for Basic Auth"
  default = "concourse"
}

variable "basic_auth_password" {
  description = "Password for Basic Auth"
  default = "concourse"
}