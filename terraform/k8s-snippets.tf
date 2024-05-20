resource "proxmox_virtual_environment_file" "cloud-init-k8s-controller-100" {
  provider     = proxmox.jupiter
  node_name    = var.proxmox_node_name
  content_type = "snippets"
  datastore_id = "local"

  source_raw {
    data = templatefile("./cloud-init/k8s-control-plane.yaml.tftpl", {
      common_config = templatefile("./cloud-init/k8s-common.yaml.tftpl", {
        hostname    = "k8s-controller-100"
        username    = var.vm_user
        password    = var.vm_password
        pub_key     = var.public_key
        k8s_version = var.k8s_version
        timezone    = "Europe/Amsterdam"
        kubeadm_cmd = "kubeadm init --skip-phases=addon/kube-proxy"
      })
      username           = var.vm_user
      cilium_cli_version = var.cilium_cli_version
      cilium_cli_cmd     = "HOME=/home/${var.vm_user} KUBECONFIG=/etc/kubernetes/admin.conf cilium install --set kubeProxyReplacement=true"
    })
    file_name = "cloud-init-k8s-controller-10.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud-init-k8s-workers" {
  # have to create a unique snippet for each worker due to the hostname.
  for_each = { for worker in var.k8s_workers : worker.id * 10 => worker }

  provider     = proxmox.jupiter
  node_name    = var.proxmox_node_name
  content_type = "snippets"
  datastore_id = "local"

  source_raw {
    data = templatefile("./cloud-init/k8s-worker.yaml.tftpl", {
      common_config = templatefile("./cloud-init/k8s-common.yaml.tftpl", {
        hostname    = "k8s-worker-${each.key}"
        username    = var.vm_user
        password    = var.vm_password
        pub_key     = var.public_key
        k8s_version = var.k8s_version
        timezone    = "Europe/Amsterdam"
        kubeadm_cmd = module.kubeadm-join.stdout
      })
    })
    file_name = "cloud-init-k8s-worker-${each.key}.yaml"
  }
}