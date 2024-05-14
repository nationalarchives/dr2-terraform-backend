variable "environments" {
  type    = list(string)
  default = []
}

variable "repositories" {
  type = list(object({ name : string, default_branch : optional(string, "main") }))
}

variable "organisation" {
  default = "nationalarchives"
}