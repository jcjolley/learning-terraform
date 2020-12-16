provider "google" {
  credentials = file("google-credentials.json")
  project = "guild-hub-296120"
  region = "us-west1"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
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

  // Use Terraform variables in the startup script
  metadata_startup_script = templatefile("resources/startup.tpl", {
    port = var.server_port,
    header = random_id.instance_id.hex
  })

  network_interface {
    network = "default"
    access_config {

    }
  }

  // allow easy ssh access
  metadata = {
    ssh-keys = "jjolley:${file("~/.ssh/id_rsa.pub")}"
  }
}

// make sure we can access the website
resource "google_compute_firewall" "default" {
  name = "express-vm-firewall"
  network = "default"
  allow {
    protocol = "tcp"
    ports = [
      var.server_port]
  }
}

// get the IP for the compute instance we spun up
output "ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip

}
