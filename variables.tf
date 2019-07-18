#####################
# General variables #
#####################
variable "api_key" {
  description = "cloud.ca API key to use"
}

############################
# Infrastructure variables #
############################
variable "environment_id" {
  description = "The environment ID to create resources in"
}

variable "network_id" {
  description = "The network ID to create resources in"
}

#####################
# Cluster variables #
#####################
variable "kubernetes_version" {
  description = "Kubernetes version to install in the cluster"
  default     = "v1.14.3-rancher1-1"
}

variable "node_prefix" {
  description = "Prefix to be used in name of instances, e.g. `cca` in `cca-foo-service01`"
  default     = "cca"
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
  default     = "rke"
}

###################
# Instances count #
###################
variable "master_count" {
  description = "Number of master node(s) to create"
  default     = 1
}

variable "worker_count" {
  description = "Number of worker node(s) to create"
  default     = 2
}
