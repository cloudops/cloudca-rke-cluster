output "master_ips" {
  description = "List of private IP of master node(s)"
  value       = module.master.private_ips
}

output "worker_ips" {
  description = "List of private IP of worker node(s)"
  value       = module.worker.private_ips
}
