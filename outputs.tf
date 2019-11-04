output "master_ips" {
  description = "List of private IP of master node(s)"
  value       = module.master.private_ips
}

output "worker_ips" {
  description = "List of private IP of worker node(s)"
  value       = module.worker.private_ips
}

resource "local_file" "private_key_pem" {
  filename          = "./generated/private_key.pem"
  file_permission   = "0600"
  sensitive_content = tls_private_key.ssh_key.private_key_pem
}

resource "local_file" "kube_cluster_yaml" {
  filename          = "./generated/kube_config.yaml"
  file_permission   = "0600"
  sensitive_content = rke_cluster.cluster.kube_config_yaml
}

resource "local_file" "rke_cluster_yaml" {
  filename          = "./generated/rke_cluster.yaml"
  file_permission   = "0600"
  sensitive_content = rke_cluster.cluster.rke_cluster_yaml
}
