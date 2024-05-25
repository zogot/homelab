data "onepassword_item" "argo-cd" {
  vault = var.onepassword_vault
  title = "ArgoCD"
}

resource "kubernetes_namespace" "argo-cd" {
  depends_on = [local_file.kube-config]
  metadata {
    name = "argo-cd"
  }
}

resource "helm_release" "argo-cd" {
  depends_on = [kubernetes_namespace.argo-cd]
  chart = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  name  = "argo-cd"
  namespace = "argo-cd"

  values = [
    "${file("helm/argo-cd.values.yaml")}"
  ]
}

resource "tls_private_key" "argocd-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#resource "onepassword_item" "argocd-ssh-key" {
#  depends_on = [tls_private_key.argocd-private-key]
#  vault = var.onepassword_vault
#
#  title = "ArgoCD - SSH Key"
#  category = "password"
#
#  section {
#    label = "OpenSSH Key"
#
#    field {
#      label = "Public Key"
#      type = "STRING"
#      value = tls_private_key.argocd-private-key.public_key_openssh
#    }
#
#    field {
#      label = "Private Key"
#      type = "STRING"
#      value = tls_private_key.argocd-private-key.private_key_openssh
#    }
#  }
#
#  section {
#    label = "PEM SSH Key"
#
#    field {
#      label = "Public Key"
#      type = "STRING"
#      value = tls_private_key.argocd-private-key.public_key_pem
#    }
#
#    field {
#      label = "Private Key"
#      type = "CONCEALED"
#      value = tls_private_key.argocd-private-key.private_key_pem
#    }
#  }
#}

resource "argocd_repository" "zogot-homelab" {
  repo = "https://github.com/zogot/homelab"
  type = "git"
}