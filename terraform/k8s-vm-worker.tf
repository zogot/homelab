resource "proxmox_virtual_environment_vm" "k8s-workers" {
  for_each = { for worker in var.k8s_workers : worker.id * 10 => worker }

  provider  = proxmox.jupiter
  node_name = var.proxmox_node_name

  name        = "k8s-worker-${each.key}"
  description = "Kubernetes Worker ${each.key}"
  tags        = ["k8s", "worker"]

  vm_id       = each.key
  on_boot     = true

  machine       = "pc"
  scsi_hardware = "virtio-scsi-single"
  bios          = "seabios"

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
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
    size         = each.value.disk_size
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
        address = "192.168.100.${each.value.id}/24"
        gateway = "192.168.100.1"
      }
    }

    datastore_id      = "local-lvm"
    user_data_file_id = proxmox_virtual_environment_file.cloud-init-k8s-workers[each.key].id
  }
}

resource "local_file" "worker-ips" {
  # loop over all workers, create new file for each
  for_each        = proxmox_virtual_environment_vm.k8s-workers

  content         = each.value.ipv4_addresses[1][0]
  filename        = "../output/terraform/${each.value.name}-ip.txt"
  file_permission = "0644"
}

output "workers_ipv4_address" {
  depends_on = [proxmox_virtual_environment_vm.k8s-workers]
  value      = {
    for k, worker in proxmox_virtual_environment_vm.k8s-workers : worker.name => worker.ipv4_addresses[1][0]
  }
}