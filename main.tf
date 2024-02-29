resource "google_compute_network" "vpc_network" {
  project                         = var.project_id
  name                            = var.vpc_name
  delete_default_routes_on_create = true
  auto_create_subnetworks         = false
  routing_mode                    = var.vpc_regional
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name                     = var.webapp_subnet_name
  ip_cidr_range            = var.webapp_subnet_cidr
  network                  = google_compute_network.vpc_network.self_link
  region                   = var.region
  private_ip_google_access = true
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
  name    = "webapp-apply-firewall"
  network = google_compute_network.vpc_network.self_link
  allow {
    protocol = "tcp"
    ports    = [var.webapp_port, "22"]
  }
  target_tags   = ["http-server"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "db_allow_firewall" {
  name    = "db-apply-firewall"
  network = google_compute_network.vpc_network.self_link
  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
  target_tags   = ["http-server"]
  source_ranges = [google_compute_subnetwork.webapp_subnet.ip_cidr_range]
}

# resource "google_compute_firewall" "webapp_deny_firewall" {
#   name    = "webapp-deny-firewall"
#   network = google_compute_network.vpc_network.self_link
#   deny {
#     protocol = "tcp"
#     ports    = ["22"]
#   }
#   source_ranges = ["0.0.0.0/0"]
# }

resource "google_compute_global_address" "internal_ip_private_access" {
  project       = google_compute_network.vpc_network.project
  name          = var.vpc_private_service_access
  address_type  = var.private_access_address_type
  purpose       = "VPC_PEERING"
  network       = google_compute_network.vpc_network.id
  prefix_length = 20
}



resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "db_instance" {
  name                = "db-instance-${random_id.db_name_suffix.hex}"
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.db_deletion_protection

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    availability_type = var.db_availability_type
    disk_type         = var.db_disk_type
    disk_size         = var.db_disk_size
    tier              = var.db_tier
    edition           = var.db_edition
    ip_configuration {
      ipv4_enabled    = var.ipv4_enabled
      private_network = google_compute_network.vpc_network.id
    }
  }
}

resource "google_sql_database" "db_webapp" {
  name     = var.db_name
  instance = google_sql_database_instance.db_instance.name
}

resource "random_password" "db_password" {
  length           = 10
  special          = true
  override_special = "*#%!()-"
}

resource "google_sql_user" "db_user" {
  name     = var.db_user
  instance = google_sql_database_instance.db_instance.name
  password = random_password.db_password.result
}


resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.internal_ip_private_access.name]
  deletion_policy         = "ABANDON"
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
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.webapp_subnet.self_link
    access_config {

    }
  }
  tags = ["http-server"]
  depends_on = [
    google_compute_subnetwork.webapp_subnet,
    google_compute_firewall.webapp_allow_firewall,
    google_compute_firewall.db_allow_firewall
  ]

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e
 
    env_file="/opt/webapp/development.env"
 
    echo "SERVER_PORT=${var.webapp_port_n}" > "$env_file"
    echo "DATABASE=${google_sql_database.db_webapp.name}" >> "$env_file"
    echo "DATABASE_SYS=${var.db_dialect}" >> "$env_file"
    echo "PORT=${var.db_port}" >> "$env_file"
    echo "HOST=${google_sql_database_instance.db_instance.ip_address.0.ip_address}" >> "$env_file"
    echo "PASSWORD=${google_sql_user.db_user.password}" >> "$env_file"
    echo "USER=${google_sql_user.db_user.name}" >> "$env_file"
  EOT

}

