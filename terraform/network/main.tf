variable "compartment" {
}

resource "libvirt_network" "net0" {
  name = "net0"
  mode = "nat"
  bridge = "virbr0"
  autostart = true
  dns { enabled = true }
  dhcp { enabled = true }
  addresses = [
    format("192.168.12%d.0/24", var.compartment)
  ]
}

resource "libvirt_network" "net1" {
  name = "net1"
  mode = "net1"
  bridge = "virbr1"
  autostart = true
  dns { enabled = true }
  dhcp { enabled = true }
  addresses = [
    format("192.168.13%d.0/24", var.compartment)
  ]
}

output "net0" {
  value = libvirt_network.net0
}

output "net1" {
  value = libvirt_network.net1
}
