variable "do_token" {
  description = "DigitalOcean Token"
  type        = string
}

variable "rebrain_ssh_key" {
  description = "Rebrain SSH Public Key Name"
  type        = string
  default     = "REBRAIN.SSH.PUB.KEY"
}

variable "do_region" {
  description = "Please enter region name"
  type        = string
}

variable "course_name" {
  description = "Rebrain course name"
  type        = string
  default     = "devops"
}

variable "email" {
  description = "Your email"
  type        = string
  default     = "e_schedrov_at_gmail_com"
}

variable "path_to_own_key" {
    description = "Path to generated SSH-key"
    type = string
}