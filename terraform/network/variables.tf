variable "username" {
    description = "Service user username for authentication"
    type = string
}

variable "project_name" {
    description = "Project name for authentication"
    type = string
}

variable "password" {
    description = "Service user password for authentication"
    type        = string
}

variable "domain_name" {
    description = "Domain name for authentication"
    type = string
}

variable "auth_url" {
    description = "Authentication URL for OpenStack"
    default = "https://api.selvpc.ru/identity/v3"
}

variable "region" {
    description = "Region for OpenStack resources"
    default = "ru-7"
}

variable "router_external_net_name" {
    description = "Name of the external network for the router"
    default = "external-network"
}

variable "router_name" {
    description = "Name of the router"
    default = "router_ru7"
}

variable "network_name" {
    description = "Name of the network"
    default = "network_ru7"
}

variable "subnet_cidr" {
    description = "CIDR block for the subnet"
    default = "192.168.0.0/24"
}