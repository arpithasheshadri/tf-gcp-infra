variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "region" {
  type        = string
  description = "Region for this infrastructure"
}

variable "vpc_name" {
  description = "Name for VPC"
}

variable "webapp_subnet_name" {
  description = "Subnet name for webapp"
}

variable "vpc_regional" {
  description = "routing mode for vpc"
}

variable "db_subnet_name" {
  description = "Subnet name for db"
}

variable "webapp_subnet_cidr" {
  description = "CIDR range for webapp"
}

variable "db_subnet_cidr" {
  description = "CIDR range for db"
}

variable "webapp_route_name" {
  description = "Router name for webapp subnet"
}

variable "webapp_route_range" {
  description = "Router range for webapp route"
}

variable "webapp_port" {
  description = "webapp application port"
}

variable "vm_name" {
  description = "The name of the VM instance"
  type        = string
}

variable "vm_zone" {
  description = "The zone for the VM instance"
  type        = string
}

variable "vm_machine_type" {
  description = "The machine type for the VM instance"
  type        = string
}

variable "vm_image" {
  description = "The custom image for the VM boot disk"
  type        = string
}

variable "vm_disk_type" {
  description = "The disk type for the VM boot disk"
  type        = string
}

variable "vm_disk_size_gb" {
  description = "The size of the VM boot disk in GB"
  type        = number
}

variable "vpc_private_service_access" {
  description = "Name of the private service access"
  type        = string
}

variable "private_ip_address" {
  description = "Ip address for private service access"
  type        = string
}

variable "forwarding_rule_name" {
  description = "Forwarding rule for private service access"
  type        = string
}

variable "private_access_address_type" {
  description = "Private access address type"
  type        = string
}

variable "database_version" {
  description = "Private access address type"
  type        = string
}

variable "db_deletion_protection" {
  description = "deletion protection for sql instance"
  type        = bool
}

variable "db_availability_type" {
  description = "database availability type"
  type        = string
}

variable "db_disk_type" {
  description = "database disk type"
  type        = string
}

variable "db_disk_size" {
  description = "database disk size"
  type        = number
}

variable "ipv4_enabled" {
  description = "ipv4 enabled value"
  type        = bool
}

variable "db_name" {
  description = "database name"
  type        = string

}

variable "db_edition" {
  description = "database edition value"
  type        = string
}

variable "db_tier" {
  description = "database tier value"
  type        = string
}

variable "db_user" {
  description = "database user"
  type        = string
}

variable "webapp_port_n" {
  type = number
}

variable "db_dialect" {
  type = string
}

variable "db_port" {
  type = string
}

variable "default_internet_gateway" {
  type = string
}

variable "tcp_port" {
  type        = string
  description = "tcp port value"
}

variable "protocol_tcp" {
  type        = string
  description = "protocol name used in firewall"
}

variable "target_tag_name" {
  type        = string
  description = "target type used in firewalls"
}

variable "webapp_allow_name" {
  type        = string
  description = "firewall name"
}

variable "db_allow_name" {
  type        = string
  description = "firewall name"
}

variable "webapp_deny_name" {
  type        = string
  description = "firewall name"
}

variable "source_ranges_cidr" {
  type        = string
  description = "firewall source ranges"
}

variable "global_address_purpose" {
  type        = string
  description = "global compute address purpose"
}

variable "prefix_address_length" {
  type        = string
  description = "prefix length for private ip address"
}

variable "deletion_policy_type" {
  type        = string
  description = "deletion policy type"
}

variable "service_networking_api" {
  type        = string
  description = "service networking gcp api"
}

variable "webapp_zone_name" {
  type        = string
  description = "zone name for webapp"
}

variable "record_type" {
  type        = string
  description = "record type for dns"
}

variable "ttl_value" {
  type        = number
  description = "ttl value"
}

variable "service_account_id" {
  type        = string
  description = "service account id"
}

variable "service_account_name" {
  type        = string
  description = "service account namr"
}

variable "service_acc_log_role" {
  type        = string
  description = "service account role value"
}

variable "service_acc_monitor_role" {
  type        = string
  description = "service account role value"
}

variable "vm_service_acc_scope" {
  type        = string
  description = "service account scopes"
}

variable "bucket_name" {
  type        = string
  description = "name of the bucket"
}

variable "archive_name" {
  type        = string
  description = "archive object name"
}

variable "app_env" {
  type        = string
  description = "Application environment variable"
}

variable "mailgun_api_key" {
  type        = string
  description = "Mailgun api key"
}

variable "mailgun_domain" {
  type        = string
  description = "Mailgun domain"
}

variable "mailgun_from_email" {
  type        = string
  description = "Mailgun from email"
}

variable "dns_name" {
  type        = string
  description = "Dns name"
}

variable "service_acc_token_creator" {
  type        = string
  description = "Token creator role"
}

variable "service_acc_roles_editor" {
  type        = string
  description = "Role editor"
}

variable "service_acc_roles_publisher" {
  type        = string
  description = "Role publisher"
}

variable "retry_policy" {
  type        = string
  description = "Retry policy"
}

variable "pubsub_event_type" {
  type        = string
  description = "Event type"
}

variable "cloud_func_entry_point" {
  type        = string
  description = "Entry point"
}

variable "node_version" {
  type        = string
  description = "Node version"
}

variable "email_function_name" {
  type        = string
  description = "Email function name"
}

variable "vpc_connector_ip" {
  type        = string
  description = "Vpc connector ip"
}

variable "vpc_connector_name" {
  type        = string
  description = "Vpc connector name"
}

variable "cloud_func_desc" {
  type        = string
  description = "Cloud function description"
}

variable "cloud_function_path" {
  type        = string
  description = "Cloud function path"
}

variable "pubsub_subscription" {
  type        = string
  description = "Pubsub subscription"
}

variable "pubsub_topic" {
  type        = string
  description = "Pubsub topic"
}

variable "bucket_region" {
  type        = string
  description = "us"
}

variable "pubsub_duration" {
  type        = string
  description = "pubsub duration"
}

variable "text_record_spf" {
  type        = string
  description = "text record spf"
}

variable "txt_record_dkim" {
  type        = string
  description = "text record dkim"
}

variable "txt_record_type" {
  type        = string
  description = "text record type"
}

variable "mx_record_1" {
  type        = string
  description = "mx record one"
}

variable "mx_record_2" {
  type        = string
  description = "mx record second"
}

variable "mx_record_type" {
  type        = string
  description = "mx record type"
}

variable "cname_record_type" {
  type        = string
  description = "cname record type"
}

variable "cname_value" {
  type        = string
  description = "cname value"
}

variable "lb_target_tag_name" {
  type        = string
  description = " health check tag name"
}

variable "firewall_direction" {
  type        = string
  description = "firewall direction"
}

variable "firewall_start_range" {
  type        = string
  description = "firewall start range"
}

variable "firewall_end_range" {
  type        = string
  description = "firewall end range"
}

variable "lb_firewall" {
  type        = string
  description = "lb firewall name"
}

variable "https_port" {
  type        = string
  description = "https port"
}

variable "healthcheck_name" {
  type        = string
  description = "healthcheck name"
}

variable "timeout_sec" {
  type        = number
  description = "timeout seconds"
}

variable "check_interval_sec" {
  type        = number
  description = "check interval seconds"
}

variable "healthy_threshold" {
  type        = number
  description = "healthy threshold"
}

variable "unhealthy_threshold" {
  type        = number
  description = "unhealthy threshold"
}

variable "gloabl_address_name" {
  type        = string
  description = "gloabl address name"
}

variable "autoscaler_name" {
  type        = string
  description = "autoscaler name"
}

variable "max_replicas" {
  type        = number
  description = "max replicas"
}

variable "min_replicas" {
  type        = number
  description = "min replicas"
}

variable "cooldown_period" {
  type        = number
  description = "cooldown period"
}

variable "https_proxy" {
  type        = string
  description = "https proxy name"
}

variable "ssl_cert_name" {
  type        = string
  description = "ssl certificate name"
}

variable "url_map" {
  type        = string
  description = "url map name"
}

variable "backend_service" {
  type        = string
  description = "backend service"
}

variable "http_port_name" {
  type        = string
  description = "http port name"
}

variable "http_protocol" {
  type        = string
  description = "http protocol"
}

variable "balancing_scheme" {
  type        = string
  description = "load balancing scheme"
}

variable "session_affinity" {
  type        = string
  description = "load balancing scheme"
}

variable "balancing_mode" {
  type        = string
  description = "load balancing mode"
}

variable "network_tier" {
  type        = string
  description = "network tier name"
}

variable "forwarding_rule" {
  type        = string
  description = "forwarding rule"
}

variable "ip_protocol" {
  type        = string
  description = "ip protocol value"
}

variable "webapp_group_manager" {
  type        = string
  description = "webapp group manager"
}

variable "initial_delay_sec" {
  type        = number
  description = "initial delay seconds"
}

variable "base_name" {
  type        = string
  description = "base instance name"
}

variable "target_size" {
  type        = number
  description = "target size"
}

variable "cloud_function_invoker_role" {
  description = "The IAM role for invoking Cloud Functions"
  type        = string
}

variable "cloud_run_invoker_role" {
  description = "The IAM role for invoking Cloud Run services"
  type        = string
}

variable "cloud_service_account_id" {
  description = "Cloud service account id"
  type        = string
}

variable "cloud_service_account_name" {
  description = "Cloud service account name"
  type        = string
}

variable "cloud_sql_key" {
  description = "cloud sql Key"
  type        = string
}

variable "bucket_key" {
  description = "bucket Key"
  type        = string
}

variable "vm_key" {
  description = "vm Key"
  type        = string
}

variable "key_ring_name" {
  description = "Key Ring"
  type        = string
}