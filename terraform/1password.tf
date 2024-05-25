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

resource "kubernetes_secret" "op-credentials" {

  metadata {
    name = "op-credentials"
    namespace = kubernetes_namespace.onepassword.metadata[0].name
    labels = {
      "app.kubernetes.io/component" = "connect"
    }
  }

  type = "opaque"

  binary_data = {
    "1password-credentials.json" = base64encode(var.onepassword_cfile)
  }
}

#resource "helm_release" "onepassword-connect" {
#  chart = "connect"
#  name  = "onepassword-connect"
#  repository = "https://1password.github.io/connect-helm-charts"
#
#  namespace = kubernetes_namespace.onepassword.metadata[0].name
#
#  set {
#    name  = "operator.create"
#    value = true
#  }
#
#  set {
#    name  = "connect.credentials_base64"
#    type = "string"
#    value = base64encode(var.onepassword_cfile)
#  }
#}

