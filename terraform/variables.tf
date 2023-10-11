variable "mento_vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_a_cidr_block" {
  default = "10.0.0.0/24"
}

variable "public_subnet_b_cidr_block" {
  default = "10.0.1.0/24"
}

variable "private_subnet_a_cidr_block" {
  default = "10.0.2.0/24"
}

variable "private_subnet_b_cidr_block" {
  default = "10.0.3.0/24"
}

variable "az-a" {
  default = "ap-northeast-2a"
}

variable "az-c" {
  default = "ap-northeast-2c"
}
