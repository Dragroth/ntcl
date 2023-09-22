resource "proxmox_virtual_environment_vm" "swarm" {
	name = "swarm-${count.index}"
	description = "Swarm test worker${count.index}"
	tags = ["terraform", "debian"]
    vm_id = 500 + count.index

	count = 3

	node_name = "hv01"
	
	agent {
		enabled = true
	}

	clone {
		datastore_id = "local-lvm"
		retries = 3
		vm_id = 9000
	}

	initialization {
    ip_config {
      ipv4 {
        address = "10.0.5.${count.index}/16"
        gateway = "10.0.0.1"
      }
    }
    user_account {
      username = "root"
      keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8f2gLQOHg2Xnnf9EyZ1A8eL1nyCh0+aZpBxj9eRowF gkk@gkk-pc", "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/zzGElglUoqeFr+siF/lulMl8kHGFwTMQcFhV3PWaH root@tool"]
    }
	}
}