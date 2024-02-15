resource "google_compute_network" "vpc_network" {
  project                         = var.project_id
  name                            = var.vpc_name
  delete_default_routes_on_create = true
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
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
  priority         = 100
}