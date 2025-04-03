variable "hosts" {}
variable "prefix_infra" {}
variable "prefix_backplane" {}
variable "prefix_storage" {}

locals {
  addresses = {
    infra = [for chunk in var.hosts :
      [for host in chunk : cidrhost(var.prefix_infra, host)]]
    backplane = [for chunk in var.hosts :
      [for host in chunk : cidrhost(var.prefix_backplane, host)]]
    storage = [for chunk in var.hosts :
      [for host in chunk : cidrhost(var.prefix_storage, host)]]
  }
}

output "return" {
  value = local.addresses
}
