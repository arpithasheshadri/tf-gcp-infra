variable "project_id" {
  type           = string
  description  = "Project ID"
}

variable "region" {
  type           = string
  description  = "Region for this infrastructure"
}

variable "vpc_name" {
  description  = "Name for VPC"
}

variable "webapp_subnet_name" {
  description  = "Subnet name for webapp"
}

variable "vpc_regional" {
  description  = "routing mode for vpc"
}

variable "db_subnet_name" {
  description  = "Subnet name for db"
}

variable "webapp_subnet_cidr" {
  description  = "CIDR range for webapp"
}

variable "db_subnet_cidr" {
  description  = "CIDR range for db"
}

variable "webapp_route_name" {
  description  = "Router name for webapp subnet"
}

variable "webapp_route_range" {
  description  = "Router range for webapp route"
}

variable "webapp_port" {
  description  = "webapp application port"
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