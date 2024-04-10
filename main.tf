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
  next_hop_gateway = var.default_internet_gateway
  priority         = 1000

}

resource "google_compute_firewall" "webapp_allow_firewall" {
  name      = var.webapp_allow_name
  network   = google_compute_network.vpc_network.self_link
  direction = var.firewall_direction
  allow {
    protocol = var.protocol_tcp
    ports    = [var.tcp_port, var.webapp_port]
  }
  target_tags   = [var.target_tag_name]
  source_ranges = [var.firewall_start_range, var.firewall_end_range]
}

resource "google_compute_firewall" "lb_firewall" {
  name          = var.lb_firewall
  direction     = var.firewall_direction
  network       = google_compute_network.vpc_network.self_link
  source_ranges = [var.firewall_start_range, var.firewall_end_range]
  allow {
    protocol = var.protocol_tcp
    ports    = [var.webapp_port, var.https_port]
  }
  target_tags = [var.target_tag_name]
}

resource "google_compute_firewall" "db_allow_firewall" {
  name    = var.db_allow_name
  network = google_compute_network.vpc_network.self_link
  allow {
    protocol = var.protocol_tcp
    ports    = [var.db_port]
  }
  target_tags   = [var.target_tag_name]
  source_ranges = [google_compute_subnetwork.webapp_subnet.ip_cidr_range]
}

resource "google_compute_firewall" "webapp_deny_firewall" {
  name    = var.webapp_deny_name
  network = google_compute_network.vpc_network.self_link
  deny {
    protocol = var.protocol_tcp
    ports    = [var.tcp_port]
  }
  source_ranges = [var.source_ranges_cidr]
}

resource "google_compute_global_address" "internal_ip_private_access" {
  project       = google_compute_network.vpc_network.project
  name          = var.vpc_private_service_access
  address_type  = var.private_access_address_type
  purpose       = var.global_address_purpose
  network       = google_compute_network.vpc_network.id
  prefix_length = var.prefix_address_length
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

  encryption_key_name = google_kms_crypto_key.crypto_key_cloudsql.id


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
  service                 = var.service_networking_api
  reserved_peering_ranges = [google_compute_global_address.internal_ip_private_access.name]
  deletion_policy         = var.deletion_policy_type
}

data "google_dns_managed_zone" "webapp_zone" {
  name = var.webapp_zone_name
}

resource "google_dns_record_set" "webapp_record" {
  name         = data.google_dns_managed_zone.webapp_zone.dns_name
  type         = var.record_type
  ttl          = var.ttl_value
  managed_zone = data.google_dns_managed_zone.webapp_zone.name

  rrdatas = [
    google_compute_global_address.webapp_lb_ip.address
  ]

}

resource "google_dns_record_set" "txt_record_spf" {
  name         = "mg.${data.google_dns_managed_zone.webapp_zone.dns_name}"
  type         = var.txt_record_type
  ttl          = var.ttl_value
  managed_zone = data.google_dns_managed_zone.webapp_zone.name

  rrdatas = [
    var.text_record_spf
  ]

}

resource "google_dns_record_set" "txt_record_dkim" {
  name         = "mailo._domainkey.mg.${data.google_dns_managed_zone.webapp_zone.dns_name}"
  type         = var.txt_record_type
  ttl          = var.ttl_value
  managed_zone = data.google_dns_managed_zone.webapp_zone.name

  rrdatas = [
    var.txt_record_dkim
  ]

}

resource "google_dns_record_set" "mx_record" {
  name         = "mg.${data.google_dns_managed_zone.webapp_zone.dns_name}"
  type         = var.mx_record_type
  ttl          = var.ttl_value
  managed_zone = data.google_dns_managed_zone.webapp_zone.name

  rrdatas = [
    var.mx_record_1, var.mx_record_2
  ]

}

resource "google_dns_record_set" "cname" {
  name         = "email.mg.${data.google_dns_managed_zone.webapp_zone.dns_name}"
  managed_zone = data.google_dns_managed_zone.webapp_zone.name
  type         = var.cname_record_type
  ttl          = var.ttl_value
  rrdatas = [
    var.cname_value
  ]
}

resource "google_pubsub_topic" "verify_pub_sub" {
  name                       = var.pubsub_topic
  message_retention_duration = var.pubsub_duration
}

resource "google_pubsub_subscription" "verify_email_subscription" {
  name                 = var.pubsub_subscription
  topic                = google_pubsub_topic.verify_pub_sub.name
  ack_deadline_seconds = 10
  push_config {
    push_endpoint = google_cloudfunctions2_function.verify_email_function.url
  }
}
resource "google_storage_bucket" "bucket" {
  name     = var.bucket_name
  location = var.region
  encryption {
    default_kms_key_name = google_kms_crypto_key.crypto_key_bucket.id
  }
  depends_on = [ google_kms_crypto_key_iam_binding.encrypter_decrypter ]
}

resource "google_storage_bucket_object" "archive" {
  name   = var.archive_name
  bucket = google_storage_bucket.bucket.name
  source = var.cloud_function_path
}

resource "google_vpc_access_connector" "vpc_connector" {
  name          = var.vpc_connector_name
  network       = google_compute_network.vpc_network.self_link
  region        = var.region
  ip_cidr_range = var.vpc_connector_ip
}

resource "google_cloudfunctions2_function" "verify_email_function" {
  name        = var.email_function_name
  description = var.cloud_func_desc
  location    = var.region

  depends_on = [google_service_account.cloud_func_service_account]
  build_config {
    runtime     = var.node_version
    entry_point = var.cloud_func_entry_point
    source {
      storage_source {
        bucket = var.bucket_name
        object = var.archive_name
      }
    }
  }
  service_config {
    max_instance_count    = 1
    available_memory      = "256M"
    service_account_email = google_service_account.service_account.email
    vpc_connector         = google_vpc_access_connector.vpc_connector.name
    environment_variables = {
      S_PORT             = "${var.webapp_port_n}"
      DB_PORT            = "${var.db_port}"
      DB_NAME            = "${var.db_name}"
      DB_DIALECT         = "${var.db_dialect}"
      DB_HOST            = "${google_sql_database_instance.db_instance.ip_address.0.ip_address}"
      DB_PASSWORD        = "${google_sql_user.db_user.password}"
      DB_USER            = "${google_sql_user.db_user.name}"
      MAILGUN_API_KEY    = "${var.mailgun_api_key}"
      MAILGUN_DOMAIN     = "${var.mailgun_domain}"
      MAILGUN_FROM_EMAIL = "${var.mailgun_from_email}"
      S_DNS_NAME         = "${var.dns_name}"
    }
  }

  event_trigger {
    service_account_email = google_service_account.cloud_func_service_account.email
    trigger_region        = var.region
    event_type            = var.pubsub_event_type
    pubsub_topic          = google_pubsub_topic.verify_pub_sub.id
    retry_policy          = var.retry_policy
  }
}

resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  provider = google-beta
  service  = "sqladmin.googleapis.com"
  project = var.project_id
}

resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  crypto_key_id = google_kms_crypto_key.crypto_key_cloudsql.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}",
  ]
}


resource "google_service_account" "cloud_storage_service_acc" {
  account_id   = "cloud-storage-service-acc"
  display_name = "Cloud Storage Service Account"
  project = var.project_id
}

resource "google_service_account" "service_account" {
  account_id   = var.service_account_id
  display_name = var.service_account_name
  project      = var.project_id
}

resource "google_service_account" "cloud_func_service_account" {
  account_id   = var.cloud_service_account_id
  display_name = var.cloud_service_account_name
  project      = var.project_id
}



resource "google_project_iam_binding" "cloud_function_invoker" {
  project = var.project_id
  role    = var.cloud_function_invoker_role
  members = [
    "serviceAccount:${google_service_account.cloud_func_service_account.email}",
  ]
}

resource "google_project_iam_binding" "cloud_run_invoker" {
  project = var.project_id
  role    = var.cloud_run_invoker_role

  members = [
    "serviceAccount:${google_service_account.cloud_func_service_account.email}",
  ]
}

resource "google_project_iam_binding" "webapp_log_binding" {
  project = var.project_id
  role    = var.service_acc_log_role

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}
resource "google_project_iam_member" "instance_admin_role" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}
resource "google_project_iam_binding" "webapp_monitor_binding" {
  project = var.project_id
  role    = var.service_acc_monitor_role

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_project_iam_binding" "pubsub_service_account_binding" {
  project = var.project_id
  role    = var.service_acc_token_creator

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}


data "google_iam_policy" "pubsub_editor" {
  binding {
    role = var.service_acc_roles_editor
    members = [
      "serviceAccount:${google_service_account.service_account.email}",
    ]
  }
}

data "google_iam_policy" "pubsub_publisher" {
  binding {
    role = var.service_acc_roles_publisher
    members = [
      "serviceAccount:${google_service_account.service_account.email}",
    ]
  }
}

resource "google_pubsub_topic_iam_policy" "publisher_policy" {
  project     = google_pubsub_topic.verify_pub_sub.project
  topic       = google_pubsub_topic.verify_pub_sub.name
  policy_data = data.google_iam_policy.pubsub_publisher.policy_data
}


resource "google_pubsub_subscription_iam_policy" "editor" {
  subscription = google_pubsub_subscription.verify_email_subscription.name
  policy_data  = data.google_iam_policy.pubsub_editor.policy_data
}



resource "google_compute_health_check" "http_health_check" {
  name        = var.healthcheck_name
  description = "Health check via http"

  timeout_sec         = var.timeout_sec
  check_interval_sec  = var.check_interval_sec
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold

  http_health_check {
    port         = var.webapp_port
    request_path = "/healthz"
  }
}


resource "google_compute_global_address" "webapp_lb_ip" {
  name = var.gloabl_address_name
}

resource "google_compute_region_autoscaler" "webapp_autoscaler" {
  name   = var.autoscaler_name
  region = var.region
  target = google_compute_region_instance_group_manager.webapp_group_manager.id
  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period
    cpu_utilization {
      target = 0.2
    }
  }
}


resource "google_compute_target_https_proxy" "webapp_https_proxy" {
  name             = var.https_proxy
  url_map          = google_compute_url_map.webapp_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.webapp_lb_ssl.id]
}

resource "google_compute_managed_ssl_certificate" "webapp_lb_ssl" {
  name = var.ssl_cert_name

  managed {
    domains = [var.dns_name]
  }
}

resource "google_compute_url_map" "webapp_url_map" {
  name        = var.url_map
  description = "webapp url map"

  default_service = google_compute_backend_service.webapp_backend_service.id

}

resource "google_compute_backend_service" "webapp_backend_service" {
  name                  = var.backend_service
  port_name             = var.http_port_name
  protocol              = var.http_protocol
  timeout_sec           = 30
  load_balancing_scheme = var.balancing_scheme
  session_affinity      = var.session_affinity
  backend {
    group           = google_compute_region_instance_group_manager.webapp_group_manager.instance_group
    balancing_mode  = var.balancing_mode
    capacity_scaler = 1.0
  }

  health_checks = [google_compute_health_check.http_health_check.id]
}

resource "google_compute_global_forwarding_rule" "webapp_rule" {
  name                  = var.forwarding_rule
  target                = google_compute_target_https_proxy.webapp_https_proxy.self_link
  port_range            = var.https_port
  ip_address            = google_compute_global_address.webapp_lb_ip.address //
  load_balancing_scheme = var.balancing_scheme
  ip_protocol           = var.ip_protocol
}

resource "google_compute_region_instance_group_manager" "webapp_group_manager" {
  name = var.webapp_group_manager

  base_instance_name        = var.base_name
  region                    = var.region
  distribution_policy_zones = ["${var.region}-b", "${var.region}-c", "${var.region}-d"]

  version {
    instance_template = google_compute_region_instance_template.cloud_vpc_instance_template.self_link
  }

  target_size = var.target_size

  named_port {
    name = var.http_port_name
    port = var.webapp_port_n
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http_health_check.self_link
    initial_delay_sec = var.initial_delay_sec
  }
}



resource "google_compute_region_instance_template" "cloud_vpc_instance_template" {
  name         = var.vm_name
  machine_type = var.vm_machine_type
  region       = var.region
  disk {
    disk_type    = var.vm_disk_type
    disk_size_gb = var.vm_disk_size_gb
    source_image = var.vm_image
    boot         = true
    auto_delete  = true
    disk_encryption_key {
      kms_key_self_link = google_kms_crypto_key.crypto_key_vms.id
    }
  }

  depends_on = [ google_kms_crypto_key_iam_binding.vm_encrypter_decrypter ]

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.webapp_subnet.self_link
    access_config {
      network_tier = var.network_tier
    }
  }
  tags = [var.target_tag_name]

  service_account {
    email  = google_service_account.service_account.email
    scopes = [var.vm_service_acc_scope]
  }
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
    echo "APP_ENV=${var.app_env}" >> "$env_file"
  EOT
}


resource "google_kms_key_ring" "webapp_keyring" {
  name     = var.key_ring_name
  location = var.region
}

resource "google_kms_crypto_key" "crypto_key_vms" {
  name            = var.vm_key
  key_ring        = google_kms_key_ring.webapp_keyring.id
  rotation_period = "2592000s"
lifecycle {
    prevent_destroy = false
  }

}

resource "google_kms_crypto_key" "crypto_key_cloudsql" {
  name            = var.cloud_sql_key
  key_ring        = google_kms_key_ring.webapp_keyring.id
  rotation_period = "2592000s"
lifecycle {
    prevent_destroy = false
  }
 
}

resource "google_kms_crypto_key" "crypto_key_bucket" {
  name            = var.bucket_key
  key_ring        = google_kms_key_ring.webapp_keyring.id
  rotation_period = "2592000s"
  lifecycle {
    prevent_destroy = false
  }
  
}

data "google_storage_project_service_account" "gcs_account" {
}


resource "google_kms_crypto_key_iam_binding" "encrypter_decrypter" {
  crypto_key_id = google_kms_crypto_key.crypto_key_bucket.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]

}


data "google_project" "project" {}

resource "google_kms_crypto_key_iam_binding" "vm_encrypter_decrypter" {
  crypto_key_id = google_kms_crypto_key.crypto_key_vms.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
  ]
}




