resource "proxmox_virtual_environment_vm" "k8s-controller-10" {
  provider = proxmox.jupiter
  node_name = var.proxmox_node_name

  name = "k8s-controller-10"
  description = "Kubernetes Control Plane 10"
  tags = ["k8s", "control-plane"]

  vm_id = 10
  on_boot = true

  machine = "pc"
  scsi_hardware = "virtio-scsi-single"
  bios = "seabios"

  cpu {
    cores = 4
    type = "host"
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr0"
    vlan_id = 100
  }

  disk {
    datastore_id = "local-lvm"
    file_id = proxmox_virtual_environment_download_file.debian_12_generic_image.id
    interface = "scsi0"
    discard = "on"
    cache = "writethrough"
    ssd = true
    size = 32
  }

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  initialization {
    dns {
      domain = var.vm_dns_domain
      servers = var.vm_dns_servers
    }

    ip_config {
      ipv4 {
        address = "192.168.100.10/24"
        gateway = "192.168.100.1"
      }
    }

    datastore_id = "local-lvm"
    user_data_file_id = proxmox_virtual_environment_file.cloud-init-k8s-controller-10.id
  }
}

resource "local_file" "k8s-controller-10-ip" {
  content         = proxmox_virtual_environment_vm.k8s-controller-10.ipv4_addresses[1][0]
  filename        = "../output/terraform/k8s-controller-10-ip.txt"
  file_permission = "0644"
}

module "kube-config" {
  depends_on   = [local_file.k8s-controller-10-ip]
  source       = "Invicton-Labs/shell-resource/external"
  version      = "0.4.1"
  command_unix = "ssh -o StrictHostKeyChecking=no ${var.vm_user}@${local_file.k8s-controller-10-ip.content} cat /home/${var.vm_user}/.kube/config"
}

resource "local_file" "kube-config" {
  content = module.kube-config.stdout
  filename = "../output/kubernetes/config"
  file_permission = "0600"
}

module "kubeadm-join" {
  depends_on   = [local_file.kube-config]
  source       = "Invicton-Labs/shell-resource/external"
  version      = "0.4.1"
  command_unix = "ssh -o StrictHostKeyChecking=no ${var.vm_user}@${local_file.k8s-controller-10-ip.content} /usr/bin/kubeadm token create --print-join-command"
  // rerun when workers update
  triggers     = [var.k8s_workers]
}

output "k8s_controller_10_ipv4_address" {
  depends_on = [proxmox_virtual_environment_vm.k8s-controller-10]
  value      = proxmox_virtual_environment_vm.k8s-controller-10.ipv4_addresses[1][0]
}