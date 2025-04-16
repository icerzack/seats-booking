# Authentication variables
variable "username" {
  description = "The username for Selectel authentication"
  type        = string
}

variable "project_name" {
  description = "The project name for Selectel authentication"
  type        = string
}

variable "password" {
  description = "The password for Selectel authentication"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "The domain name for Selectel authentication"
  type        = string
}

variable "auth_url" {
  description = "The authentication URL for Selectel"
  type        = string
  default     = "https://api.selvpc.ru/identity/v3"
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "ru-7"
}

# Network variables
variable "router_external_net_name" {
  description = "The name of the external network"
  type        = string
  default     = "external-network"
}

variable "router_name" {
  description = "The name for the router"
  type        = string
  default     = "router_ru7"
}

variable "network_name" {
  description = "The name for the network"
  type        = string
  default     = "network_ru7"
}

variable "subnet_cidr" {
  description = "The CIDR for the subnet"
  type        = string
  default     = "192.168.0.0/24"
}

variable "server_vcpus" {
  description = "Number of VCPUs for the server"
  type        = number
  default     = 2
}

variable "server_ram_mb" {
  description = "Amount of RAM in MB for the server"
  type        = number
  default     = 2048
}

variable "server_root_disk_gb" {
  description = "Size of the root disk in GB"
  type        = number
  default     = 10
}

variable "server_name" {
  description = "Name for the server"
  type        = string
  default     = "seats-booking-server"
}

variable "image_name" {
  description = "Name of the image to use for the server"
  type        = string
  default     = "Ubuntu 22.04 LTS 64-bit"
}

variable "server_zone" {
  description = "Availability zone for the server"
  type        = string
  default     = "ru-7a"
}
