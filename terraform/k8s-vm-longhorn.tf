resource "proxmox_virtual_environment_file" "cloud-init-k8s-worker-500" {
  provider     = proxmox.jupiter
  node_name    = var.proxmox_node_name
  content_type = "snippets"
  datastore_id = "local"

  source_raw {
    data = templatefile("./cloud-init/k8s-worker.yaml.tftpl", {
      common_config = templatefile("./cloud-init/k8s-common.yaml.tftpl", {
        hostname    = "k8s-worker-500"
        username    = var.vm_user
        password    = var.vm_password
        pub_key     = var.public_key
        k8s_version = var.k8s_version
        timezone    = "Europe/Amsterdam"
        kubeadm_cmd = module.kubeadm-join.stdout
      })
    })
    file_name = "cloud-init-k8s-worker-500.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "k8s-worker-500" {
  provider  = proxmox.jupiter
  node_name = var.proxmox_node_name

  name        = "k8s-worker-500"
  description = "Kubernetes Worker 500"
  tags        = ["k8s", "worker", "storage"]

  vm_id       = 500
  on_boot     = true

  machine       = "pc"
  scsi_hardware = "virtio-scsi-single"
  bios          = "seabios"

  cpu {
    cores = 1
    type  = "host"
  }

  memory {
    dedicated = 1024*2
  }

  network_device {
    bridge = "vmbr0"
    vlan_id = 100
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.debian_12_generic_image.id
    interface    = "scsi0"
    cache        = "writethrough"
    discard      = "on"
    ssd          = true
    size         = 500
  }

  boot_order = ["scsi0"]

  agent {
    enabled = true
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 6.X.
  }

  initialization {
    dns {
      domain  = var.vm_dns_domain
      servers = var.vm_dns_servers
    }
    ip_config {
      ipv4 {
        address = "192.168.100.50/24"
        gateway = "192.168.100.1"
      }
    }

    datastore_id      = "local-lvm"
    user_data_file_id = proxmox_virtual_environment_file.cloud-init-k8s-worker-500.id
  }
}