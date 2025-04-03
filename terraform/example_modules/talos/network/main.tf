variable "compartments" { default = 2 }
variable "prefix_infra" { default = "192.168.124.0/24" }
variable "prefix_backplane" { default = "192.168.190.0/24" }
variable "prefix_storage" {}
variable "controlplane_nodes" { default = 2 }
variable "storage_nodes" { default = 2 }
variable "worker_nodes" { default = 4 }

module "controlplane_hosts" {
  source       = "./hosts"
  compartments = var.compartments
  start        = local.start_controlplane
  nodes        = var.controlplane_nodes
  chunk        = local.chunk_controlplane
}

module "storage_hosts" {
  source       = "./hosts"
  compartments = var.compartments
  start        = local.start_storage
  nodes        = var.storage_nodes
  chunk        = local.chunk_storage
}

module "worker_hosts" {
  source       = "./hosts"
  compartments = var.compartments
  start        = local.start_workers
  nodes        = var.worker_nodes
  chunk        = local.chunk_workers
}

module "controlplane_addresses" {
  source           = "./addresses"
  hosts            = module.controlplane_hosts.return
  prefix_infra     = var.prefix_infra
  prefix_backplane = var.prefix_backplane
  prefix_storage   = var.prefix_storage
}

module "storage_addresses" {
  source           = "./addresses"
  hosts            = module.storage_hosts.return
  prefix_infra     = var.prefix_infra
  prefix_backplane = var.prefix_backplane
  prefix_storage   = var.prefix_storage
}

module "worker_addresses" {
  source           = "./addresses"
  hosts            = module.worker_hosts.return
  prefix_infra     = var.prefix_infra
  prefix_backplane = var.prefix_backplane
  prefix_storage   = var.prefix_storage
}

locals {
  // 1-10 service
  // 11-20 controlplane
  // 21-30 storage
  // 31-99 workers
  // 100-250 dynamic nodes

  max_controlplane = 10
  max_storage      = 10
  max_workers      = 30

  start_controlplane = 30
  start_storage      = local.start_controlplane + local.max_controlplane
  start_workers      = local.start_storage + local.max_storage

  chunk_controlplane = floor(local.max_controlplane / var.compartments)
  chunk_storage      = floor(local.max_storage / var.compartments)
  chunk_workers      = floor(local.max_workers / var.compartments)

}

output "controlplane" {
  value = module.controlplane_addresses.return
}

output "storage" {
  value = module.storage_addresses.return
}

output "worker" {
  value = module.worker_addresses.return
}
