variable "git_path" {
  description = "Provide path to your namespace from Gitlab"
  type = string
}

variable "url" {
  description = "my own repo url"
  default     = "https://gitlab.rebrainme.com/"
  type        = string
}

variable "ssh_path" {
  description = "Path to public key"
  type = string
}

variable "token" {
  description = "Token for working with Gitlab API"
  type = string
}