variable "project_id" {
  type           = string
  description  = "Project ID"
}

variable "region" {
  type           = string
  description  = "Region for this infrastructure"
}

variable "vpcs" {
  type        = map(object({
    vpc_name            = string
    webapp_subnet_name  = string
    db_subnet_name      = string
    webapp_subnet_cidr  = string
    db_subnet_cidr      = string
    webapp_route_name   = string
    webapp_route_range  = string
  }))
  description = "Map of VPC configurations"
}
