terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

variable "node_count" {
  default     = "3"
  description = "Vm number to be created"
}

provider "google" {
  credentials = file("yourCredential")
  project     = "yourProject"
  region      = "europe-west1"
  zone        = "europe-west1-c"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-nw"
}

resource "google_compute_firewall" "external-tcp" {
  name    = "external-tcp"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "6443", "443","2379","8080"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "internal-tcp-access" {
  name    = "k8-internal-tcp-access"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
  }
  source_ranges = ["10.132.0.0/20"]
}

resource "google_compute_firewall" "internal-udp-access" {
  name    = "k8-internal-udp-access"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "udp"
  }
  source_ranges = ["10.132.0.0/20"]
}

resource "google_compute_firewall" "external-icmp-terraformnw" {
  name    = "k8-internal-icmp-access"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "internal-ipip-access" {
  name    = "k8-internal-ipip-access"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "ipip"
  }
  source_ranges = ["10.132.0.0/20"]
}


resource "google_compute_instance" "vm_instance-" {
  count                     = var.node_count
  name                      = "server-${count.index}"
  machine_type              = "e2-medium"
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }
  metadata = {
    ssh-keys = "demouser:${file("yourpublicKey")}"
  }
}



