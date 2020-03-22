#
# Variables Configuration
#

variable "cluster-name" {
  default = "terraform-eks-demo"
  type    = string
}

variable "access_key_id" {
  type    = string
  default = "" # Put here your creds
}

variable "secret_access_key" {
  type    = string
  default = "" # put here your creds
}

variable "zone" {
  type    = string
  default = "us-east-1"
}



