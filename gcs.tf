resource "google_storage_bucket_iam_member" "publicBucket" {
    bucket = google_storage_bucket.static-site.id
    member = "allUsers"
    role = "roles/storage.objectViewer"
}

resource "google_storage_bucket" "static-site" {
  project       = google_project.service_project.project_id
  name          = "jkwng-website-${random_id.random_suffix.hex}"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  cors {
    origin          = ["https://${var.dns_name}"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_object" "index_en" {
    bucket = google_storage_bucket.static-site.name
    name = "en/index.html"
    source = "${path.module}/static-site/index-en.html"
}

resource "google_storage_bucket_object" "index_fr" {
    bucket = google_storage_bucket.static-site.name
    name = "fr/index.html"
    source = "${path.module}/static-site/index-fr.html"
}