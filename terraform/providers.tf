terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://root@172.16.254.186/system"
}

provider "libvirt" {
  alias = "serverA"
  uri   = "qemu+ssh://root@server-a.local/system"
}

provider "libvirt" {
  alias = "serverB"
  uri   = "qemu+ssh://root@server-b.local/system"
}
