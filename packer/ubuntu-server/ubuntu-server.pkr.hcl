# Ubuntu Server
# ---
# Packer Template to create an Ubuntu Server on Proxmox

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
  default = "8000"
}

source "proxmox-iso" "ubuntu-server" {

    # Proxmox Connection Settings
    proxmox_url               = var.proxmox_api_url
    username                  = var.proxmox_api_token_id
    token                     = var.proxmox_api_token_secret
    insecure_skip_tls_verify  = false

    # VM General Settings
    node                  = var.proxmox_node
    vm_id                 = var.vm_id
    vm_name               = "ubuntu-server"
    template_description  = "Built from ${basename(var.iso_file)} on ${formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())}"
    cores                 = "2"
    memory                = "2048"
    qemu_agent            = true

    # ISO file
    iso_url               = "https://releases.ubuntu.com/jammy/ubuntu-22.04.3-live-server-amd64.iso"
    iso_checksum          = "a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
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
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot            = "c"
    boot_wait       = "5s"

    # PACKER Autoinstall Settings
    http_directory  = "http" 

    ssh_username    = "ubuntu"
    # (Option 1) Add your Password here
    # ssh_password = "packer"
    # - or -
    # (Option 2) Add your Private SSH KEY file here
    ssh_private_key_file = "~/.ssh/id_ed25519"

    # Raise the timeout, when installation takes longer
    ssh_timeout = "20m"
}

build {
    name    = "ubuntu-server"
    sources = ["source.proxmox-iso.ubuntu-server"]

    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    provisioner "file" {
        source      = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }
}