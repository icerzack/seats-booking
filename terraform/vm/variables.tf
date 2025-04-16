variable "username" {
    description = "Service user username for authentication"
    type        = string
}

variable "project_name" {
    description = "Project name for authentication"
    type        = string
}

variable "password" {
    description = "Service user password for authentication"
    type        = string
}

variable "domain_name" {
    description = "Domain name for authentication"
    type        = string
}

variable "auth_url" {
    description = "Authentication URL for OpenStack"
    default = "https://api.selvpc.ru/identity/v3"
}

variable "region" {
    description = "Region for OpenStack resources"
    default = "ru-7"
}

variable "server_vcpus" {
    description = "Number of virtual CPUs for the server"
  default = 1
}

variable "server_ram_mb" {
    description = "Amount of RAM for the server in MB"
    default = 1024
}

variable "server_root_disk_gb" {
    description = "Size of the root disk for the server in GB"
    default = 10
}

variable "server_name" {
    description = "Name of the server"
    default = "Server-for-DevOps"
}

variable "image_name" {
    description = "Name of the server image"
    default = "Ubuntu 22.04 LTS 64-bit"  
}

variable "server_zone" {
    description = "Availability zone for the server"
    default = "ru-7a"
}

variable "network_id" {
    description = "ID of the network"
    type        = string
}

variable "floatingip_address" {
    description = "Floating IP address from the network module"
    type        = string
}

variable "cloud_init_content" {
  description = "Content for cloud-init configuration"
  type        = string
}
