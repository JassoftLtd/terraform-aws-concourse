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
  type = "list"
  description = "CIDR for the Private Subnet"
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "availability_zones" {
  type        = "list"
  description = "The availability zones"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
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

# DNS
variable "dns_zone_id" {
  description = "Amazon Route53 DNS zone identifier"
}

variable "dns_zone_name" {
  description = "Amazon Route53 DNS zone name"
}