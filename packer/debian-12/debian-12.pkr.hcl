# Debian 12 (bookworm)
# ---
# Packer Template to create an Debian 12 on Proxmox

packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variable Definitions

# PVE connection
variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

# VM variables
variable "iso_file" {
  type    = string
  default = "local:iso/ubuntu-22.04.3-live-server-amd64.iso"
}

variable "cloudinit_storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "proxmox_node" {
  type    = string
  default = "hv01"
}

variable "storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "cpu_type" {
  type    = string
  default = "host"
}

variable "vm_id" {
  type    = string
  default = "8010"
}


source "proxmox-iso" "debian-12" {

  # Proxmox Connection Settings
  proxmox_url               = var.proxmox_api_url
  username                  = var.proxmox_api_token_id
  token                     = var.proxmox_api_token_secret
  insecure_skip_tls_verify  = false

  # VM General Settings
  node                  = var.proxmox_node
  vm_id                 = var.vm_id
  vm_name               = "debian-12"
  template_description  = "Built from ${basename(var.iso_file)} on ${formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())}"
  cores                 = "2"
  memory                = "2048"
  qemu_agent            = true

  # ISO file
  iso_url               = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.1.0-amd64-netinst.iso"
  iso_checksum          = "9f181ae12b25840a508786b1756c6352a0e58484998669288c4eec2ab16b8559"
  iso_storage_pool      = "local"
  unmount_iso           = true

  # VM Hard Disk Settings
  scsi_controller       = "virtio-scsi-pci"
  disks {
    disk_size     = "10G"
    storage_pool  = var.storage_pool
    type          = "virtio"
  }

  # VM Network Settings
  network_adapters {
    model     = "virtio"
    bridge    = "vmbr100"
    firewall  = "false"
  }
  
  # VM Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = var.cloudinit_storage_pool
  # PACKER Boot Commands
  boot_command    = [
    "<down><down><down><down>",
    "<wait><enter>",
    "<wait>auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"
  ]
  boot            = "c"
  boot_wait       = "5s"

  # PACKER Autoinstall Settings
  http_directory  = "http" 
  ssh_username    = "root"
  # (Option 1) Add your Password here
  ssh_password = "packer" # temporary password
  # - or -
  # (Option 2) Add your Private SSH KEY file here
  # ssh_private_key_file = "~/.ssh/id_ed25519"
  # Raise the timeout, when installation takes longer
  ssh_timeout = "20m"
}

build {
  name    = "debian-12"
  sources = ["source.proxmox-iso.debian-12"]

  provisioner "file" {
    destination = "/etc/cloud/cloud.cfg"
    source      = "files/cloud.cfg"
  }
    
  provisioner "file" {
    destination = "/etc/cloud/99-pve.cfg"
    source      = "files/99-pve.cfg"
  }

}