resource "kubernetes_namespace" "onepassword" {
  metadata {
    name = "onepassword"
  }
}

resource "kubernetes_secret" "op-connect-token" {
  metadata {
    name = "onepassword-token"
    namespace = kubernetes_namespace.onepassword.metadata[0].name
  }
  type = "generic"
  data = {
    token = var.onepassword_opct
  }

}
