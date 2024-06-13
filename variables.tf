variable "aws_vpc" {
  type        = string
  description = "AWS VPC"

}

variable "public_subnet1" {
  type        = string
  description = "Public Subnet 1"

}

variable "public_subnet2" {
  type        = string
  description = "Public Subnet 1"

}


variable "private_subnet1" {
  type        = string
  description = "Private Subnet 1"

}

variable "private_subnet2" {
  type        = string
  description = "Private Subnet 1"

}


variable "ami" {
  description = "EC2 ami"
  type        = string
  default     = ""
}


variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.large"
}

