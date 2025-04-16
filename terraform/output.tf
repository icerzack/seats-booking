output "vm_floatingip" {
  description = "The public IP address of the VM"
  value       = module.vm.floatingip_address
}