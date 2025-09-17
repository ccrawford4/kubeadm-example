resource "google_compute_network" "application_network" {
  name = "application-network"
}

resource "google_compute_firewall" "http_nodeport" {
    name    = "http-nodeport-firewall"
    network = google_compute_network.application_network.name

    allow {
      protocol = "icmp"
    }

    allow {
      protocol = "tcp"
      ports    = ["22", "80", "443", "6443", "8443", "9443", "9153", "30007"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags   = ["application"]
  }
