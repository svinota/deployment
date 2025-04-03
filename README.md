
```
├── README.md
└── terraform
    ├── example_modules          # additional examples
    │   ├── k8s                  # this module defines Talos on VMs
    │   │   ├── libvirt.tf
    │   │   ├── main.tf
    │   │   └── providers.tf
    │   └── talos                # this module defines Talos config
    │       ├── main.tf
    │       ├── network
    │       │   ├── addresses
    │       │   │   └── main.tf
    │       │   ├── hosts
    │       │   │   └── main.tf
    │       │   └── main.tf
    │       ├── providers.tf
    │       └── README.md
    ├── infra                    # this module defines Fedora based VMs
    │   ├── cloud_init.yaml
    │   ├── main.tf
    │   └── providers.tf
    ├── main.tf                  # main() -- the main entry point
    ├── network                  # this module defines libvirt networks
    │   ├── main.tf              # the same way it is possibe to define
    │   └── providers.tf         # storage pools and other libvirt entities
    └── providers.tf
```
