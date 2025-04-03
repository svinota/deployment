variable "network" {}
variable "secrets" {}
variable "compartment" {}
variable "index" {}
variable "hostname" {}
variable "gateway" {}
variable "role" {}

data "talos_machine_configuration" "this" {
  cluster_name     = var.network.cluster_name
  machine_type     = var.role == "controlplane" ? "controlplane" : "worker"
  cluster_endpoint = var.network.cluster_endpoints[0]
  machine_secrets  = var.secrets
  docs             = false
  examples         = false
  config_patches = [
    var.role == "controlplane" ? yamlencode(
      {
        machine = {
          network = {
            interfaces = [
              {
                interface = "eth0"
                vip = {
                  ip = var.network.vip
                }
              }
            ]
          }
        }
      }) : "",
    yamlencode(
      {
        machine = {
          install = {
            disk = "/dev/vda"
          }
          certSANs = var.network.sans
          time = {
            servers = [var.gateway]
          }
          network = {
            nameservers = [var.gateway]
            interfaces = [
              {
                interface = "eth0"
                dhcp      = false
                mtu       = 1500
                addresses = [
                format("%s/24", var.network.role[var.role].infra[var.compartment][var.index])]
                routes = [
                  {
                    network = "0.0.0.0/0"
                    gateway = var.gateway
                  },
                ]
              },
              {
                interface = "eth1"
                dhcp      = false
                mtu       = 65520
                addresses = [
                format("%s/24", var.network.role[var.role].backplane[var.compartment][var.index])]
              },
              {
                interface = "eth2"
                dhcp      = false
                mtu       = 65520
                addresses = [
                format("%s/24", var.network.role[var.role].storage[var.compartment][var.index])]
              }
            ]
            hostname = var.hostname
          }
        }
        cluster = {
          allowSchedulingOnControlPlanes = true
        }
      }
    )
  ]
}
