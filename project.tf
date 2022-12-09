data "google_project" "dns_project" {
  project_id = var.dns_project_id
}

resource "random_id" "random_suffix" {
  byte_length = 2
}

data "google_billing_account" "acct" {
  billing_account = var.billing_account_id
}

data "google_folder" "parent" {
  folder = "folders/${var.parent_folder_id}"
}

resource "google_project" "service_project" {
  billing_account = data.google_billing_account.acct.id

  name = "${var.service_project_id}-${random_id.random_suffix.hex}"
  project_id = "${var.service_project_id}-${random_id.random_suffix.hex}"
  auto_create_network = false
  folder_id = data.google_folder.parent.id
}




