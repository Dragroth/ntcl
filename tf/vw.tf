resource "proxmox_virtual_environment_vm" "vw" {
	name = "vw"
	description = "Vaultwarden"
	tags = ["terraform", "debian", "docker", "loc"]
    vm_id = 103

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
			address = "10.0.0.103/16"
			gateway = "10.0.0.1"
		}
    }
		user_account {
			username = "debian"
			keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8f2gLQOHg2Xnnf9EyZ1A8eL1nyCh0+aZpBxj9eRowF gkk@gkk-pc", "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/zzGElglUoqeFr+siF/lulMl8kHGFwTMQcFhV3PWaH root@tool", "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkgjghRdGy9dV5ptQ0EhGOZHYAzyAmA3NBVBGSiMLPSZk1xm1rxNUGuxom1pdggchNR//mVIjJNwJrJ9qitsKiaifNpV6vsS/ThOTJkzzPU/94mKAjZDL+44sQ2yWCwZsGD//Vml5BydrBkBjIWqHHU2iH9GPF/HZMhLrYy3AWFrnQRYyNWXZ7wTOnfVpNuNm2yIIY2nx02TUHUIszSG8g4HfmHFN9yH0HfO0Cg6uTHvB1UbetVeYbxH5qa1I3QDJIEKbR31bAzK+fyDNL7EwvcbepAiPkR1BvnayRggzn3P46ABLgA00hHKvIo+v+rKcHj1x2aVZ9nRPa7j95l0QrweVdU6nSnCxe2vhG3almTyXek+SWhWdTfTouXFAgBKJDFh3SlLXVCyruSx9esfq1tVN+Bl+B/7I3Pa12OOLRgPMJCWLwjBKoZb36GOz1YE8LcW06LrYHkyXUpvAqqjBJIkHsc/oMVqjVp6tgAfzHcTtKzuG7Z2H/401miFgZocc= gabrielkról@DESKTOP-GEK0378"]
		}
	}
}