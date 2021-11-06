variable "vpcCidrBlock" {
  description = "CIDR Block for VPC"
  default     = "10.10.10.0/24"
  type        = string
}

variable "PublicSubnet1Cidr" {
  description = "CIDR Block for Public Subnet 1"
  default     = "10.10.10.0/26"
  type        = string
}

variable "PublicSubnet2Cidr" {
  description = "CIDR Block for Public Subnet 2"
  default     = "10.10.10.64/26"
  type        = string
}

variable "PrivateSubnet1Cidr" {
  description = "CIDR Block for Private Subnet 1"
  default     = "10.10.10.128/26"
  type        = string
}

variable "PrivateSubnet2Cidr" {
  description = "CIDR Block for Private Subnet 2"
  default     = "10.10.10.192/26"
  type        = string
}

variable "userdataPath" {
  description = "Path to EC2 Userdata"
  default     = "~/projects/terraform/udemy/02/userdata.sh"
}
