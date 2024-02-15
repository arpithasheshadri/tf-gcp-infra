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
