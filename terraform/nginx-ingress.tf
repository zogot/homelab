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