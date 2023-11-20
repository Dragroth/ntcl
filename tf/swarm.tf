resource "proxmox_virtual_environment_vm" "docker" {
	name = "docker0"
	description = "Docker host 0"
	tags = ["terraform", "debian", "docker"]
    vm_id = 120

	node_name = "hv01"
	
	agent {
		enabled = true
	}

	clone {
		datastore_id = "local-lvm"
		retries = 3
		vm_id = 8010
	}

	initialization {
		ip_config {
		ipv4 {
			address = "10.0.0.120/16"
			gateway = "10.0.0.1"
		}
    }
		user_account {
			username = "debian"
			keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8f2gLQOHg2Xnnf9EyZ1A8eL1nyCh0+aZpBxj9eRowF gkk@gkk-pc", "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/zzGElglUoqeFr+siF/lulMl8kHGFwTMQcFhV3PWaH root@tool"]
		}
	}
}