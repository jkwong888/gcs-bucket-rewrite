resource "google_project_organization_policy" "public_bucket" {
  project    = google_project.service_project.project_id
  constraint = "constraints/storage.publicAccessPrevention"

  boolean_policy {
    enforced = false
  } 
}

resource "google_project_organization_policy" "allow_all_domains" {
  project    = google_project.service_project.project_id
  constraint = "constraints/iam.allowedPolicyMemberDomains"

  list_policy {
    allow {
      all = true
    }
  } 
}
