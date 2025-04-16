resource "random_string" "random_name" {
  length  = 5
  special = false
}

resource "openstack_compute_flavor_v2" "flavor_1" {
  name      = "flavor-${random_string.random_name.result}"
  ram       = var.server_ram_mb
  vcpus     = var.server_vcpus
  disk      = var.server_root_disk_gb

  lifecycle {
    create_before_destroy = true
  }
}

data "openstack_images_image_v2" "image_1" {
  name        = var.image_name
  visibility  = "public"
  most_recent = true
}

resource "openstack_compute_instance_v2" "instance_1" {
  name              = var.server_name
  image_id          = data.openstack_images_image_v2.image_1.id
  flavor_id         = openstack_compute_flavor_v2.flavor_1.id
  availability_zone = var.server_zone
  admin_pass 	      = "12345678"
  user_data         = var.cloud_init_content

  network {
    uuid = var.network_id
  }

  timeouts {
    create = "30m"
  }

  lifecycle {
    ignore_changes = [image_id]
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = var.floatingip_address
  instance_id = openstack_compute_instance_v2.instance_1.id
}
