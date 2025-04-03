variable "compartments" {}
variable "nodes" {}
variable "chunk" {}
variable "start" {}

locals {
  hosts = [for offset in
    [for compartment in
    range(var.compartments) : var.chunk * compartment] :
  range(
    var.start + offset,
    var.start + offset + min(floor(var.nodes / var.compartments), var.chunk))]
}

output "return" {
  value = local.hosts
}
