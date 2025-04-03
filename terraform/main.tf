
module "network_serverA" {
  source      = "./network"    # ./ is important as it points to a local file
  compartment = 0              # an argument to the function
  providers = {
    libvirt = libvirt.serverA  # which provider (here: server) to use for this code block
  }
}

module "network_serverB" {
  source      = "./network"
  compartment = 1
  providers = {
    libvirt = libvirt.serverB
  }
}

module "infra_serverA" {
  count  = 1                            # number of servers: `count` creates a declarative loop
  name   = "infra-A"                    # servers will be named infra-A-0, infra-A-1 etc.
  index  = tonumber(count.index)        # current server index in the loop
  source = "./infra"                    # ./ is important as it points to a local file
  net0   = module.network_serverA.net0  # pass an object from above as an argument
  providers = {
    libvirt = libvirt.serverA           # which provider (here: server) to use for this code block
  }
}

module "infra_serverB" {
  count  = 1
  name   = "infra-B"
  index  = tonumber(count.index)
  source = "./infra"
  net0   = module.network_serverB.net0
  providers = {
    libvirt = libvirt.serverB
  }
}
