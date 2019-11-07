resource "cloudca_instance" "node" {
  environment_id   = var.environment_id
  network_id       = var.network_id
  name             = format("%s-%s-%s-%s%02d", var.node_prefix, var.node_type, var.node_service, var.node_role, count.index + 1)
  compute_offering = "Standard"
  cpu_count        = 4
  memory_in_mb     = 16384
  template         = "Ubuntu 18.04.3 LTS x64"
  ssh_key_name     = var.ssh_key_name
  user_data        = var.cloudinit_data
  count            = var.node_count
}
