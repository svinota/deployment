variable "net0" {}
variable "net_macvtap" {
  type = list(string)
  default = ["eth1"]
}
variable "name" {
  type = string
  default = "infra"
}
variable "index" {}
variable "memory" {
  type = number
  default = 2048
}
variable "disk" {
  type = number
  default = 5
}
locals {
  base_image = "Fedora-Cloud-Base-39-1.5.x86_64.qcow2"
}

data "template_file" "user_data" {
  # our cloud_init file is a template, here we can substitute
  # variables in it
  template = templatefile("${path.module}/cloud_init.yaml",
    {
      fqdn = "${var.name}-${var.index}"
    }
  )
}

resource "libvirt_cloudinit_disk" "this" {
  # resource of type libvirt_cloudinit_disk takes user_data
  # and packs it into an ISO
  name = "${var.name}-cloudinit-${var.index}.iso"
  user_data = data.template_file.user_data.rendered
}

resource "libvirt_volume" "this" {
  name             = "${var.name}-${var.index}.qcow2"
  base_volume_name = local.base_image
  size             = 1073741824 * var.disk  # terraform has no concept of megabytes etc.
}

resource "libvirt_domain" "this" {
  name    = "${var.name}-${var.index}"
  vcpu    = 2
  memory  = var.memory
  running = true
  boot_device {
    # boot from hd, if possible; else from CD
    #
    # in our case hd is a cloud image (bootable); CD will be plugged
    # while booting only to provide cloud init
    dev = ["hd", "cdrom"]
  }
  disk {
    volume_id = libvirt_volume.this.id
  }
  disk {
    file = "/var/lib/libvirt/images/${libvirt_cloudinit_disk.this.name}"
  }
  network_interface {
    network_id = var.net0.id
    hostname   = "${var.name}-${var.index}"
  }
  dynamic "network_interface" {
    for_each = toset(var.net_macvtap)
    content {
      macvtap = network_interface.value
    }
  }
  # provide the console interface
  console {
    type        = "pty"
    target_port = 0
    target_type = "serial"
  }
}
