locals {
  app_name = split(".", var.dns_name)[0]
  dns_domain_split = split(".", var.dns_name)
  dns_domain = join(".", slice(local.dns_domain_split, 1, length(local.dns_domain_split)))
}

data "google_dns_managed_zone" "env_dns_zone" {
  provider = google-beta
  name = var.dns_zone
  project   = data.google_project.dns_project.project_id
}

resource "google_dns_record_set" "app" {
  provider      = google-beta
  managed_zone  = data.google_dns_managed_zone.env_dns_zone.name
  project       = data.google_project.dns_project.project_id
  name          = "${var.dns_name}."
  type          = "A"
  rrdatas       = [
    google_compute_global_address.app.address
  ]
  ttl          = 300
}

resource "google_compute_global_address" "app" {
  name      = "${local.app_name}"
  project   = google_project.service_project.project_id
}

resource "google_compute_global_forwarding_rule" "app-https" {
  name        = "${local.app_name}-https"
  target      = google_compute_target_https_proxy.app.id
  port_range  = "443"
  ip_address  = google_compute_global_address.app.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  project     = google_project.service_project.project_id
}

resource "google_compute_managed_ssl_certificate" "app" {
  name      = "${local.app_name}"
  project   = google_project.service_project.project_id

  managed {
    domains = ["${var.dns_name}."]
  }
}

resource "google_compute_target_https_proxy" "app" {
  name              = "${local.app_name}"
  url_map           = google_compute_url_map.app.id
  ssl_certificates  = [google_compute_managed_ssl_certificate.app.id]
  project           = google_project.service_project.project_id
}

resource "google_compute_url_map" "app" {
  name            = "${local.app_name}"
  description     = "app"
  default_service = google_compute_backend_bucket.bucket.id
  project         = google_project.service_project.project_id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_bucket.bucket.id

    route_rules {
      priority = 1000
      service = google_compute_backend_bucket.bucket.id
      match_rules {
        prefix_match = "/"
        ignore_case = true
        header_matches {
          header_name = "accept-language"
          regex_match = ".*en-[^;]+;.*"
        }
      }
      route_action {
        url_rewrite {
          path_prefix_rewrite = "/en/"
        }
      }
    }

    route_rules {
      priority = 1001
      service = google_compute_backend_bucket.bucket.id
      match_rules {
        prefix_match = "/"
        ignore_case = true
        header_matches {
          header_name = "accept-language"
          regex_match = ".*fr-[^;]+;.*"
        }
      }
      route_action {
        url_rewrite {
          path_prefix_rewrite = "/fr/"
        }
      }
    }
  }
}

resource "google_compute_backend_bucket" "bucket" {
  name        = "${local.app_name}-bucket"
  bucket_name = google_storage_bucket.static-site.name
  project     = google_project.service_project.project_id
  enable_cdn  = true

}

