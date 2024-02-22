resource "google_compute_network" "vpc_network" {
  project                         = var.project_id
  name                            = var.vpc_name
  delete_default_routes_on_create = true
  auto_create_subnetworks         = false
  routing_mode                    = var.vpc_regional
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = var.webapp_subnet_name
  ip_cidr_range = var.webapp_subnet_cidr
  network       = google_compute_network.vpc_network.self_link
  region        = var.region
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = var.db_subnet_name
  ip_cidr_range = var.db_subnet_cidr
  network       = google_compute_network.vpc_network.self_link
  region        = var.region
}

resource "google_compute_route" "webapp_route" {
  name             = var.webapp_route_name
  dest_range       = var.webapp_route_range 
  network          = google_compute_network.vpc_network.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
  
}

resource "google_compute_firewall" "webapp_allow_firewall" {
  name          = "webapp-apply-firewall"
  network       = google_compute_network.vpc_network.self_link
  allow {
    protocol = "tcp"
    ports    = [var.webapp_port,"80"]
  }
  target_tags = ["http-server"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "webapp_deny_firewall" {
  name          = "webapp-deny-firewall"
  network       = google_compute_network.vpc_network.self_link
  deny {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "cloud_vpc_instance" {
  name         = var.vm_name
  machine_type = var.vm_machine_type
  zone         = var.vm_zone
  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = var.vm_disk_size_gb
      type  = var.vm_disk_type
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.webapp_subnet.self_link
    access_config {
    
  }
  }
  tags = ["http-server"]
  depends_on = [
    google_compute_subnetwork.webapp_subnet,
    google_compute_firewall.webapp_allow_firewall
  ]
}
