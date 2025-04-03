provider "openstack" {
  auth_url    = var.auth_url
  domain_name = var.domain_name
  tenant_name = var.project_name
  user_name   = var.username
  password    = var.password
  region      = var.region
}

module "network" {
  source = "./network"

  username               = var.username
  project_name           = var.project_name
  password               = var.password
  domain_name            = var.domain_name
  auth_url               = var.auth_url
  region                 = var.region
  router_external_net_name = var.router_external_net_name
  router_name            = var.router_name
  network_name           = var.network_name
  subnet_cidr            = var.subnet_cidr
}

module "vm" {
  source = "./vm"

  depends_on = [module.network]
  
  username          = var.username
  project_name      = var.project_name
  password          = var.password
  domain_name       = var.domain_name
  auth_url          = var.auth_url
  region            = var.region
  server_vcpus      = var.server_vcpus
  server_ram_mb     = var.server_ram_mb
  server_root_disk_gb = var.server_root_disk_gb
  server_name       = var.server_name
  image_name        = var.image_name
  server_zone       = var.server_zone
  network_id        = module.network.network_id
  floatingip_address = module.network.floatingip_address
  cloud_init_file   = var.cloud_init_file
}
