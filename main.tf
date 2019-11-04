provider "cloudca" {
  version = "~> 1.5"
  api_key = var.api_key
}

provider "rke" {
  version = "0.14.1"
}

terraform {
  required_version = "> 0.12.0"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "cloudca_ssh_key" "ssh_key" {
  environment_id = var.environment_id
  name           = "${format("%s-%s-%s_key", var.node_prefix, var.node_type, var.node_service)}"
  public_key     = "${replace(tls_private_key.ssh_key.public_key_openssh, "\n", "")}"
}

data "template_file" "cloudinit" {
  template = "${file("${path.module}/files/cloud-init.yaml")}"

  vars = {
    username   = var.node_username
    public_key = replace(tls_private_key.ssh_key.public_key_openssh, "\n", "")
  }
}

module "master" {
  source          = "./nodes"
  node_prefix     = var.node_prefix
  node_type       = var.node_type
  node_service    = var.node_service
  node_count      = var.master_count
  node_role       = "master"
  node_username   = var.node_username
  environment_id  = var.environment_id
  network_id      = var.network_id
  ssh_key_name    = cloudca_ssh_key.ssh_key.name
  private_key_pem = tls_private_key.ssh_key.private_key_pem
  cloudinit_data  = data.template_file.cloudinit.rendered
}

module "worker" {
  source          = "./nodes"
  node_prefix     = var.node_prefix
  node_type       = var.node_type
  node_service    = var.node_service
  node_count      = var.worker_count
  node_role       = "worker"
  node_username   = var.node_username
  environment_id  = var.environment_id
  network_id      = var.network_id
  ssh_key_name    = cloudca_ssh_key.ssh_key.name
  private_key_pem = tls_private_key.ssh_key.private_key_pem
  cloudinit_data  = data.template_file.cloudinit.rendered
}

resource "rke_cluster" "cluster" {
  depends_on = [module.master.nodes_ready, module.worker.nodes_ready]

  kubernetes_version = var.kubernetes_version
  cluster_name       = format("%s-%s", var.node_type, var.node_service)

  dynamic "nodes" {
    iterator = node
    for_each = module.master.private_ips

    content {
      address = node.value
      user    = var.node_username
      ssh_key = tls_private_key.ssh_key.private_key_pem
      role    = ["controlplane", "etcd"]
    }
  }

  dynamic "nodes" {
    iterator = node
    for_each = module.worker.private_ips

    content {
      address = node.value
      user    = var.node_username
      ssh_key = tls_private_key.ssh_key.private_key_pem
      role    = ["worker"]
    }
  }
}
