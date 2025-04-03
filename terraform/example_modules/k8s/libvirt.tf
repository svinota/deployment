
variable "eth0" { default = "eth2" }
variable "pool" {
  default = {
    name = "default"
    path = "/var/lib/libvirt/images"
  }
}

variable "size1G" {
 type = number
  default = 1073741824
} 
variable "size10G" {
  type    = number
  default = 10737418240
}

resource "libvirt_cloudinit_disk" "this" {
  name      = "${var.hostname}.iso"
  pool      = var.pool.name
  user_data = data.talos_machine_configuration.this.machine_configuration
}

resource "libvirt_volume" "this" {
  name             = "${var.hostname}.qcow2"
  base_volume_name = "nocloud-amd64.qcow2"
  pool             = var.pool.name
  size             = var.role == "controlplane" ? var.size10G : (
                     var.role == "worker" ? var.size10G * 2 : (
                     var.role == "storage" ? var.size10G : var.size10G ) )
}

resource "libvirt_volume" "storage" {
  name = "${var.hostname}-storage.qcow2"
  pool = var.pool.name
  size = var.role == "storage" ? var.size10G * 20 : var.size1G
}

resource "libvirt_domain" "this" {
  depends_on = [
    libvirt_cloudinit_disk.this,
    libvirt_volume.this,
    libvirt_volume.storage,
  ]
  name = var.hostname
  vcpu = 2
  cpu { mode = "host-model" }
  memory  = var.role == "controlplane" ? 1024 * 2 : (
            var.role == "worker" ? 1024 * 8 : (
            var.role == "storage" ? 1024 * 2 : 1024 ) )
  running = true
  boot_device {
    dev = ["hd"]
  }
  disk {
    volume_id = libvirt_volume.this.id
  }
  disk {
    volume_id = libvirt_volume.storage.id
  }
  disk {
    file = "${var.pool.path}/${var.hostname}.iso"
  }
  network_interface {
    macvtap  = var.eth0
    hostname = var.hostname
  }
  console {
    type        = "pty"
    target_port = 0
    target_type = "serial"
  }
}
