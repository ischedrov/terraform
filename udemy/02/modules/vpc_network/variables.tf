variable "vpcCidrBlock" {
  description = "CIDR Block for VPC"
  default     = "10.10.10.0/24"
  type        = string
}

variable "PublicSubnetsCidr" {
  description = "CIDR Blocks for Public Subnets"
  default     = ["10.10.10.0/26", "10.10.10.64/26"]
  type        = list(string)
}

variable "PrivateSubnetsCidr" {
  description = "CIDR Blocks for Private Subnets"
  default     = ["10.10.10.128/26", "10.10.10.192/26"]
  type        = list(string)
}

variable "userdataPath" {
  description = "Path to EC2 Userdata"
  default     = "~/projects/terraform/udemy/02/userdata.sh"
}
