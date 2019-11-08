output "private_ips" {
  description = "Map of private IP of node(s)"
  value       = zipmap(cloudca_instance.node.*.private_ip, cloudca_instance.node.*.private_ip_id)
}

output "nodes_ready" {
  depends_on = ["null_resource.node_setup"]
  value      = "true"
}
