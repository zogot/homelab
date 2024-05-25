resource "proxmox_virtual_environment_container" "pihole" {
  provider = proxmox.jupiter
  description = "PiHole DNS - Set in USG"

  node_name = var.proxmox_node_name
  vm_id = 800

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
    swap = 512
  }

  initialization {
    hostname = "pihole"

    dns {
      servers = var.vm_dns_servers
    }

    ip_config {

      ipv4 {
        address = "192.168.100.80/24"
        gateway = "192.168.100.1"
      }
    }

    user_account {
      keys = [var.public_key, tls_private_key.terraform_key.public_key_openssh]
      password = "password"
    }
  }

  features {
    nesting = true
  }

  unprivileged = true

  network_interface {
    name = "vmbr0"
    vlan_id = 100
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.debian_12_lxc.id
    type = "debian"
  }

  disk {
    datastore_id = "local-lvm"
    size = 4
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }


  provisioner "remote-exec" {
    inline = [
      "mkdir /etc/pihole"
    ]

    connection {
      host = "192.168.100.80"
      type = "ssh"
      user = "root"
      private_key = tls_private_key.terraform_key.private_key_pem
    }
  }

  provisioner "file" {
    content = templatefile("./config-files/pihole/setupVars.conf", {
      password = var.pihole_hashed_password // replace with hasing here from password from 1password
    })
    destination = "/etc/pihole/setupVars.conf"

    connection {
      host = "192.168.100.80"
      type = "ssh"
      user = "root"
      private_key = tls_private_key.terraform_key.private_key_pem
    }
  }

  provisioner "remote-exec" {
    inline = [
      "apt update && apt upgrade -y",
      "apt install curl -y",
      "curl -L https://install.pi-hole.net | bash /dev/stdin --unattended",
      "echo Done!"
    ]

    connection {
      host = "192.168.100.80"
      type = "ssh"
      user = "root"
      private_key = tls_private_key.terraform_key.private_key_pem
    }
  }
}
