resource "kubernetes_secret" "onepassword-service-account" {

  metadata {
    name = "service-account"
  }

  type = "generic"

  data = {
    token = var.onepassword_sat
  }
}

resource "helm_release" "onepassword-secrets-injector" {
  chart = "secrets-injector"
  name  = "onepassword-secrets-injector"
  repository = "https://1password.github.io/connect-helm-charts"
}