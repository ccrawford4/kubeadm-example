resource "google_compute_firewall" "http_nodeport" {
  name    = "http-nodeport-firewall"
  network = google_compute_network.application_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["30007"]
  }

  source_tags = ["application"]
}

resource "google_compute_network" "application_network" {
  name = "application-network"
}
