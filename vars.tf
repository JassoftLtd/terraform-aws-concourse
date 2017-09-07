variable "aws_access_key" {
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
}

variable "aws_region" {
  description = "AWS Region"
  default     = "eu-west-1"
}

variable "keys_bucket_name" {
  description = "S3 bucket to store keys in"
  default     = "concourse-keys"
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = "list"
  description = "CIDR for the Public Subnet"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr" {
  type        = "list"
  description = "CIDR for the Private Subnet"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  type        = "list"
  description = "The availability zones"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "whitelist_ips" {
  type        = "list"
  description = "IPs that are able to access Concourse"
  default     = ["0.0.0.0/0"]
}

variable "private_workers" {
  description = "Should be workers be placed in a private sebnet with a NAT gateway"
  default     = true
}

variable "key_name" {
  description = "Key pair name"
}

variable "github_auth_client_id" {
  description = "GitHub Client Id"
}

variable "github_auth_client_secret" {
  description = "GitHub Client Secret"
}

variable "github_auth_team" {
  description = "GitHub Team Name"
}

# DNS
variable "dns_zone_name" {
  description = "Amazon Route53 DNS zone name. (Don't include trailing dot)"
}

# Concourse
variable "concourse_version" {
  description = "The version on concourse to deploy"
  default     = "v3.3.3"
}

# Workers
variable "concourse_workers_min_instances" {
  description = "The Minimum number of Concourse Workers to run"
  default     = 1
}

variable "concourse_workers_max_instances" {
  description = "The Maximum number of Concourse Workers to run"
  default     = 10
}
