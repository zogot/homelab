resource "kubernetes_namespace" "ingress-nginx" {
  depends_on = [local_file.kube-config]

  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress-nginx" {
  depends_on = [kubernetes_namespace.ingress-nginx]

  chart = "ingress-nginx"
  name  = "ingress-nginx"
  namespace = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version = "4.10.1"
}