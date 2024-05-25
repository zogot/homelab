resource "kubernetes_namespace" "argo-cd" {
  depends_on = [local_file.kube-config]
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argo-cd" {
  depends_on = [kubernetes_namespace.argo-cd]
  chart = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  name  = "argo-cd"
  namespace = "argocd"

  wait = true

  values = [
    "${file("helm/argo-cd.values.yaml")}"
  ]
}

resource "tls_private_key" "argocd-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}