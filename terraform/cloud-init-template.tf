locals {
  cloud_init_content = file("${path.module}/cloud-init.yaml")
} 