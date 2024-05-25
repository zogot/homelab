locals {
  cloudflare-dns-solver = {
    cloudflare = {
      email = data.onepassword_item.cloudflare-api.username
      apiKeySecretRef = {
        name = "cloudflare-api-key"
        key = "global"
      }
    }
  }
}

data "onepassword_item" "cloudflare-api" {
  vault = var.onepassword_vault
  title = "Cloudflare Token"
}

resource "kubernetes_namespace" "external-dns-cloudflare" {
  metadata {
    name = "external-dns-cloudflare"
  }
}



resource "helm_release" "external-dns-cloudflare" {

  chart = "external-dns"
  name  = "external-dns-cloudflare"
  namespace = kubernetes_namespace.external-dns-cloudflare.metadata[0].name
  repository = "https://kubernetes-sigs.github.io/external-dns/"

  values = [
    templatefile("helm/external-dns-cloudflare.values.yaml", {
      vault = var.onepassword_vault,
      item = "Cloudflare Token"
    })
  ]
}