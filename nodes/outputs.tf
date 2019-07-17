output "private_ips" {
  description = "List of private IP of node(s)"
  value       = cloudca_instance.node.*.private_ip
}

output "nodes_ready" {
  depends_on = ["null_resource.node_setup"]
  value      = "true"
}
