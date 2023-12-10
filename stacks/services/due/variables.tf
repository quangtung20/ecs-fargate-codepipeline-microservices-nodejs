variable "fgms_due_service_namespace" {
  description = "fgms due service namespace"
  default     = "fgms-due-service"
}

variable "repo_name" {
  type    = string
  default = "due-repo"
}

variable "branch_name" {
  type    = string
  default = "master"
}

variable "build_project" {
  type    = string
  default = "due-dev-build-repo"
}

variable "uri_repo" {
  type    = string
  default = "quangtung20/due"
}

