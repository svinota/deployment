#!/bin/bash

for tool in tofu jq yq; do {
	which $tool >/dev/null 2>&1 || {
		echo "$tool not found"
		exit 1
	}
} done
#
# Create ansible inventory from terraform state
#
# Here we list all the libvirt VMs under terraform control,
# and get the first IP address on the first interface.
#
# The resulting inventory be like:
#
# all:
#   children:
#     site:
#       hosts:
#         infra-A-0:
#           name: infra-A-0
#           ansible_host: 192.168.121.250
#           ansible_user: admin
#         infra-B-0:
#           name: infra-B-0
#           ansible_host: 192.168.120.67
#           ansible_user: admin
#
# Server names: see terraform/main.tf
# Server addresses: see terraform/network/main.tf
#
# Ansible user is hardcoded into the jq request, see below
#

function dump() {
	tofu show -json | \
		jq '
			.values.root_module.child_modules[] |
			select(.address | test("module.infra.*")) |
			.resources[] |
			select(.address | test(".*libvirt_domain.*")) |
			.values.network_interface[] |
			select(.addresses | length > 0) |
			{(.hostname): {
				name: .hostname, 
				ansible_host: .addresses[0],
				ansible_user: "admin"
			}}' | \
		jq -s 'reduce .[] as $item ({}; . + $item)' | \
		yq -P eval '{"all": {"children": {"site": {"hosts": .}}}}'
}

#
# Run the function in the terraform directory
#
pushd ../terraform >/dev/null
tofu refresh
dump | tee ../ansible/inventory/site.yml
popd >/dev/null
