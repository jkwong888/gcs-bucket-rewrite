variable "billing_account_id" {
  default = ""
}

variable "organization_id" {
  default = "614120287242" // jkwng.altostrat.com
}

variable "parent_folder_id" {
  default = "297737034934" // dev
}

variable "service_project_id" {
  description = "The ID of the service project which hosts cloud dns e.g. dev-55427"
}

variable "service_project_apis_to_enable" {
  type = list(string)
  default = [
    "compute.googleapis.com",
    "storage.googleapis.com",
  ]
}

variable "region" {
  default = "us-central1"
}

variable "dns_project_id" {
  description = "The ID of the service project which hosts cloud dns e.g. dns-55427"
}

variable "dns_zone" {}
variable "dns_name" {}