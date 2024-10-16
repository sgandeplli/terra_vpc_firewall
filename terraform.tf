provider "google" {
  //credentials = file("/home/hr377/gcp.json")
  project = "primal-gear-436812-t0"  # Replace with your project ID
  region  = "us-central1"           # Change to your preferred region
}

# Step 1: Create a VPC
resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}

# Step 2: Create a Subnetwork
resource "google_compute_subnetwork" "subnetwork" {
  name          = "my-subnetwork"
  ip_cidr_range = "10.0.0.0/24"  # Change as needed
  region       = "us-central1"    # Must match the region of the VPC
  network      = google_compute_network.vpc_network.name
}

# Step 3: Create a Firewall Rule
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]  # Allow SSH from anywhere; change as needed
}

# Step 4: Create a Compute Instance
resource "google_compute_instance" "vm_instance" {
  name         = "my-instance"
  machine_type = "e2-micro"  # Change as needed
  zone         = "us-central1-b"   # Change as needed

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-9"  # Change as needed
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnetwork.name

    access_config {
      // Ephemeral IP
    }
  }

  tags = ["ssh"]  # Optional: use tags for firewall rules
}

output "instance_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

