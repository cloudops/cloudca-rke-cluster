output "master_ips" {
  description = "List of private IP of master node(s)"
  value       = module.master.private_ips
}

output "worker_ips" {
  description = "List of private IP of worker node(s)"
  value       = module.worker.private_ips
}

output "master_endpoint_ips" {
  description = "List of master endpoint IPs to access the clusters externally"
  value       = cloudca_public_ip.master_ip_endpoint.*.ip_address
}
