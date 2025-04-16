output "vm_floatingip" {
  description = "The public IP address of the VM"
  value       = module.vm.floatingip_address
}

output "frontend_url" {
  description = "Frontend application URL (available after cloud-init completes)"
  value       = "http://${module.vm.floatingip_address}:30080"
}

output "backend_url" {
  description = "Backend API URL (available after cloud-init completes)"
  value       = "http://${module.vm.floatingip_address}:30008"
}

output "deployment_info" {
  description = "Information about deployment and monitoring"
  value       = <<-EOT
    The application is being deployed through cloud-init.
    
    Full deployment may take 10-15 minutes to complete.
    
    After deployment completes, you can SSH to the VM and check:
    - Deployment status: `cat /root/app-info.txt`
    - Run load test: `/root/load-test.sh`
    - Monitor autoscaling: `kubectl -n seats-booking get hpa backend-hpa -w`
    
    To SSH into the machine: ssh ubuntu@${module.vm.floatingip_address}
  EOT
}