resource "cloudca_instance" "node" {
  environment_id   = var.environment_id
  network_id       = var.network_id
  name             = format("%s-%s-%s-%s%02d", var.node_prefix, var.node_type, var.node_service, var.node_role, count.index + 1)
  compute_offering = "Standard"
  cpu_count        = 4
  memory_in_mb     = 16384
  template         = "Ubuntu 18.04.2"
  ssh_key_name     = var.ssh_key_name
  user_data        = var.cloudinit_data
  count            = var.node_count
}

resource "cloudca_volume" "volume" {
  environment_id = var.environment_id
  name           = format("%s-%s-%s-%s%02d_DATA", var.node_prefix, var.node_type, var.node_service, var.node_role, count.index + 1)
  size_in_gb     = 100
  disk_offering  = "Guaranteed Performance, 1000 iops min"
  instance_id    = element(cloudca_instance.node.*.id, count.index)
  count          = var.node_count
}

resource "null_resource" "mount_volume" {
  count      = var.node_count
  depends_on = ["cloudca_instance.node", "cloudca_volume.volume"]

  provisioner "remote-exec" {
    inline = [
      "if [ -d /data ]; then exit 0; fi",
      "sudo mkdir /data",
      "sudo parted /dev/xvdb mklabel gpt mkpart ext4 0 100% i",
      "sudo mkfs.ext4 /dev/xvdb1",
      "echo '/dev/xvdb1    /data    ext4    defaults    0 2' | sudo tee -a /etc/fstab",
      "sudo mount -a",
    ]
  }

  connection {
    type        = "ssh"
    user        = var.node_username
    host        = element(cloudca_instance.node.*.private_ip, count.index)
    private_key = var.private_key_pem
  }
}

resource "null_resource" "node_setup" {
  count      = var.node_count
  depends_on = ["null_resource.mount_volume"]

  provisioner "remote-exec" {
    inline = [
      "swapoff -a"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com | sudo bash",
      "sudo systemctl start docker.service",
      "sudo systemctl enable docker.service",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "if [ ! -d /data/ -o ! -r /data/ ]; then exit 0; fi",
      "if [ -d /data/var-lib-docker/ ]; then exit 0; fi",
      "sudo mkdir -p /data/var-lib-docker",
      "sudo systemctl stop docker",
      "sudo mv /var/lib/docker /data/var-lib-docker",
      "sudo ln -s /data/var-lib-docker /var/lib/docker",
      "sudo systemctl start docker",
    ]
  }

  connection {
    type        = "ssh"
    user        = var.node_username
    host        = element(cloudca_instance.node.*.private_ip, count.index)
    private_key = var.private_key_pem
  }
}
