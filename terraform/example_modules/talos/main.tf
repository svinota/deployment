variable "compartments" {}
variable "prefix_infra" {}
variable "prefix_backplane" {}
variable "prefix_storage" {}
variable "controlplane_nodes" {}
variable "storage_nodes" {}
variable "worker_nodes" {}

module "network" {
  source = "./network"
  compartments = var.compartments
  prefix_infra = var.prefix_infra
  prefix_backplane = var.prefix_backplane
  prefix_storage = var.prefix_storage
  controlplane_nodes = var.controlplane_nodes
  storage_nodes = var.storage_nodes
  worker_nodes = var.worker_nodes
}

locals {
  vip = cidrhost(var.prefix_infra, 9)
  nodes = flatten([
    flatten(module.network.controlplane.infra),
    flatten(module.network.storage.infra),
    flatten(module.network.worker.infra),
  ])
  network = {
    cluster_name = "k8s"
    cluster_endpoints = [format("https://%s:6443", local.vip)]
    vip = local.vip
    sans = flatten([local.nodes, [local.vip]])
    nodes = local.nodes
    role = {
      controlplane = module.network.controlplane
      storage = module.network.storage
      worker = module.network.worker
    }
  }
}

resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "this" {
  cluster_name         = local.network.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = local.network.cluster_endpoints
  nodes                = local.network.nodes
}

output "network" {
  value = local.network
}

output "secrets" {
  value = talos_machine_secrets.this.machine_secrets
}

output "talosconfig" {
  value = data.talos_client_configuration.this.talos_config
}
