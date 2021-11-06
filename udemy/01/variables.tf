
variable "tags" {
  description = "Default tags"
  type        = map(any)
  default = {
    Stage      = "Test",
    Created_by = "Ivan Schedrov"
  }
}

variable "userdataPath" {
  description = "Path to userdata file"
}