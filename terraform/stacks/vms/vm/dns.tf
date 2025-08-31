resource "google_dns_managed_zone" "calum_run" {
  name     = "calum-run-zone"
  dns_name = "calum.run."
  
  description = "DNS zone for calum.run"
}

resource "google_dns_record_set" "calum_run_a" {
  name = "calum.run."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.calum_run.name

  rrdatas = [var.ingress_external_ip]
}

resource "google_dns_record_set" "calum_run_www" {
  name = "www.calum.run."
  type = "CNAME"
  ttl  = 300

  managed_zone = google_dns_managed_zone.calum_run.name

  rrdatas = ["calum.run."]
}

variable "ingress_external_ip" {
  description = "External IP of the ingress controller"
  type        = string
}