output "router_id" {
    description = "The ID of the router"
    value = openstack_networking_router_v2.router_1.id
}

output "network_id" {
    description = "The ID of the network"
    value = openstack_networking_network_v2.network_1.id
}

output "subnet_id" {
    description = "The ID of the subnet"
    value = openstack_networking_subnet_v2.subnet_1.id
}

output "floatingip_id" {
    description = "The ID of the floating IP"
    value = openstack_networking_floatingip_v2.floatingip_1.id
}

output "floatingip_address" {
    description = "The public IP address assigned to the instance"
    value = openstack_networking_floatingip_v2.floatingip_1.address
}