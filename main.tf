resource "google_compute_network" "vpc_network" {
  for_each                       = var.vpcs
  project                        = var.project_id
  name                           = each.value.vpc_name
  delete_default_routes_on_create = true
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
}

resource "google_compute_subnetwork" "webapp_subnet" {
  for_each        = var.vpcs
  name            = each.value.webapp_subnet_name
  ip_cidr_range   = each.value.webapp_subnet_cidr
  network         = google_compute_network.vpc_network[each.key].self_link
  region          = var.region
}

resource "google_compute_subnetwork" "db_subnet" {
  for_each        = var.vpcs
  name            = each.value.db_subnet_name
  ip_cidr_range   = each.value.db_subnet_cidr
  network         = google_compute_network.vpc_network[each.key].self_link
  region          = var.region
}

resource "google_compute_route" "webapp_route" {
  for_each        = var.vpcs
  name            = each.value.webapp_route_name
  dest_range      = each.value.webapp_route_range
  network         = google_compute_network.vpc_network[each.key].self_link
  next_hop_gateway = "default-internet-gateway"
  priority        = 100
}
