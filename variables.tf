#####################
# General variables #
#####################
variable "api_key" {
  description = "cloud.ca API key to use"
}

variable "students" {
  description = "list of students in the workshop"
  type        = "list"
}

############################
# Infrastructure variables #
############################
variable "environment_id" {
  description = "The environment ID to create resources in"
}

variable "vpc_id" {
  description = "The vpc ID to be used"
}


variable "network_id" {
  description = "The network ID to create resources in"
}

#####################
# Cluster variables #
#####################
variable "kubernetes_version" {
  description = "Kubernetes version to install in the cluster"
  default     = "v1.15.3-rancher1-1"
}

variable "node_prefix" {
  description = "Prefix to be used in name of instances, e.g. `cca` in `cca-foo-service01`"
  default     = "wkp"
}

variable "node_type" {
  description = "Type to be used in name of instances, e.g. `foo` in `cca-foo-service01`"
  default     = "cluster"
}

variable "node_service" {
  description = "Service to be used in name of instances, e.g. `service` in `cca-foo-service01`"
  default     = "rke"
}

variable "node_username" {
  description = "The username to create in the nodes with SSH access"
  default     = "student"
}

variable "node_password" {
  description = "The password to the created instances"
  default     = "$6$rounds=4096$PrIHpY39x6Qu/89Q$kBz3eWhgABARVDPhv1XVkCgEftdBdVh1Y7v940krZba4TL9QoKU.Q5WtuaHCQIt.WrjOqiq.Ud6M7Lsg9g9yD1"
}

###################
# Instances count #
###################
variable "worker_count" {
  description = "Number of worker node(s) to create"
  default     = 2
}
