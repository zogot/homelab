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