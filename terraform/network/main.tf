data "openstack_networking_network_v2" "external_net" {
  name     = var.router_external_net_name
  external = true
}

resource "openstack_networking_router_v2" "router_1" {
  name                = var.router_name
  external_network_id = data.openstack_networking_network_v2.external_net.id
}

resource "openstack_networking_network_v2" "network_1" {
  name = var.network_name
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  network_id      = openstack_networking_network_v2.network_1.id
  name            = var.subnet_cidr
  cidr            = var.subnet_cidr
  enable_dhcp     = false
  dns_nameservers = ["188.93.16.19", "188.93.17.19"]
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}

resource "openstack_networking_floatingip_v2" "floatingip_1" {
  pool = "external-network"
}