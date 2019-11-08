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

module "master" {
  source         = "./nodes"
  node_prefix    = var.node_prefix
  node_type      = var.node_type
  node_service   = var.node_service
  node_count     = length(var.students)
  node_role      = "master"
  node_username  = var.node_username
  environment_id = var.environment_id
  network_id     = var.network_id
  ssh_key_name   = cloudca_ssh_key.ssh_key.name
  cloudinit_data = templatefile("${path.module}/files/cloud-init.yaml", { username = var.node_username, password = var.node_password, public_key = replace(tls_private_key.ssh_key.public_key_openssh, "\n", "") })
}

module "worker" {
  source         = "./nodes"
  node_prefix    = var.node_prefix
  node_type      = var.node_type
  node_service   = var.node_service
  node_count     = var.worker_count * length(var.students)
  node_role      = "worker"
  node_username  = var.node_username
  environment_id = var.environment_id
  network_id     = var.network_id
  ssh_key_name   = cloudca_ssh_key.ssh_key.name
  cloudinit_data = templatefile("${path.module}/files/cloud-init.yaml", { username = var.node_username, password = var.node_password, public_key = replace(tls_private_key.ssh_key.public_key_openssh, "\n", "") })
}

resource "cloudca_public_ip" "master_ip_endpoint" {
  count          = length(var.students)
  environment_id = var.environment_id
  vpc_id         = var.vpc_id
}


resource "cloudca_static_nat" "master_nat" {
  depends_on     = [module.master.nodes_ready, cloudca_public_ip.master_ip_endpoint]
  count          = length(var.students)
  environment_id = var.environment_id
  public_ip_id   = element(cloudca_public_ip.master_ip_endpoint.*.id, count.index)
  private_ip_id  = element(values(module.master.private_ips), count.index)
}

resource "null_resource" "wait" {
  depends_on = [module.master.nodes_ready, module.worker.nodes_ready, cloudca_static_nat.master_nat]
  count      = length(var.students)

  provisioner "file" {
    source      = "${path.module}/files/wait.sh"
    destination = "/tmp/wait.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/wait.sh",
      "/tmp/wait.sh",
    ]
  }

  connection {
    type        = "ssh"
    user        = var.node_username
    host        = element(cloudca_public_ip.master_ip_endpoint.*.ip_address, count.index)
    private_key = tls_private_key.ssh_key.private_key_pem
  }

}
resource "rke_cluster" "cluster" {
  depends_on = [null_resource.wait]
  count      = length(var.students)

  kubernetes_version = var.kubernetes_version
  cluster_name       = format("%s-%s-%s", var.node_prefix, var.node_type, var.students[count.index])

  bastion_host {
    address = element(cloudca_public_ip.master_ip_endpoint.*.ip_address, count.index)
    ssh_key = tls_private_key.ssh_key.private_key_pem
    user    = var.node_username
  }

  nodes {
    address = keys(module.master.private_ips)[count.index]
    user    = var.node_username
    ssh_key = tls_private_key.ssh_key.private_key_pem
    role    = ["controlplane", "etcd"]
  }

  dynamic "nodes" {
    iterator = node
    for_each = chunklist(keys(module.worker.private_ips), var.worker_count)[count.index]

    content {
      address = node.value
      user    = var.node_username
      ssh_key = tls_private_key.ssh_key.private_key_pem
      role    = ["worker"]
    }
  }
}

resource "local_file" "private_key_pem" {
  filename          = "./generated/private_key.pem"
  file_permission   = "0600"
  sensitive_content = tls_private_key.ssh_key.private_key_pem
}

resource "null_resource" "master_config" {
  depends_on = [rke_cluster.cluster]
  count      = length(var.students)

  provisioner "remote-exec" {
    inline = [
      "mkdir ~/.kube"
    ]
  }
  provisioner "file" {
    content     = rke_cluster.cluster[count.index].kube_config_yaml
    destination = format("/home/%s/.kube/config", var.node_username)
  }
  provisioner "file" {
    content     = rke_cluster.cluster[count.index].rke_cluster_yaml
    destination = format("/home/%s/cluster.yaml", var.node_username)
  }
  connection {
    type        = "ssh"
    user        = var.node_username
    host        = element(cloudca_public_ip.master_ip_endpoint.*.ip_address, count.index)
    private_key = tls_private_key.ssh_key.private_key_pem
  }
}
