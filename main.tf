provider "google" {
  credentials = file("google-credentials.json")
  project = "guild-hub-296120"
  region = "us-west1"
}

// Generate a random id
resource "random_id" "instance_id" {
  byte_length = 8
}

// Create a google Compute Engine

resource "google_compute_instance" "default" {
  name = "express-vm-${random_id.instance_id.hex}"
  machine_type = "f1-micro"
  zone = "us-west1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential rsync"

  network_interface {
    network = "default"
    access_config {

    }
  }

  metadata = {
    ssh-keys = "jjolley:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "google_compute_firewall" "default" {
  name = "express-vm-firewall"
  network = "default"
  allow {
    protocol = "tcp"
    ports = ["8080"]
  }
}


output "ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}
