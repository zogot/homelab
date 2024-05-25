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

resource "kubernetes_manifest" "ingress-class-internal" {
  for_each = toset(["internal", "external"])
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind = "IngressClass"
    metadata = {
      name = each.value
    }

    spec = {
      controller = "k8s.io/ingress-nginx"
    }
  }
}