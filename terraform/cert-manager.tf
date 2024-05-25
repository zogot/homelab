#resource "kubernetes_namespace" "cert-manager" {
#  metadata {
#    name = "cert-manager"
#  }
#}
#
#resource "helm_release" "cert-manager" {
#  chart = "cert-manager"
#  repository = "https://charts.jetstack.io"
#  name  = "cert-manager"
#  namespace = kubernetes_namespace.cert-manager.metadata[0].name
#
#  wait = true
#
#  set {
#    name  = "installCRDs"
#    value = "true"
#  }
#}

#resource "kubernetes_manifest" "cloudflare-api-key-cert-manager" {
#  manifest = {
#    apiVersion = "onepassword.com/v1"
#    kind = "OnePasswordItem"
#    metadata = {
#      name = "cloudflare-api-key"
#      namespace = kubernetes_namespace.cert-manager.metadata[0].name
#    }
#
#    spec = {
#      itemPath = "vaults/${var.onepassword_vault}/items/Cloudflare Token"
#    }
#
#  }
#}
#
#resource "kubernetes_manifest" "cluster-issuer-letsencrypt-staging" {
#  depends_on = [helm_release.cert-manager]
#  manifest = {
#    apiVersion = "cert-manager.io/v1"
#    kind = "ClusterIssuer"
#    metadata = {
#      name = "letsencrypt-staging"
#    }
#    spec = {
#      acme = {
#        email = "home@rowland.nl"
#        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
#        privateKeySecretRef = {
#          name = "rowland-issuer-account-key"
#        }
#        solvers = [
#          {
#            "dns01" = local.cloudflare-dns-solver
#          }
#        ]
#      }
#    }
#  }
#}
#
#resource "kubernetes_manifest" "cluster-issuer-letsencrypt-prod" {
#  depends_on = [helm_release.cert-manager]
#  manifest = {
#    apiVersion = "cert-manager.io/v1"
#    kind = "ClusterIssuer"
#    metadata = {
#      name = "letsencrypt-prod"
#    }
#    spec = {
#      acme = {
#        email = "home@rowland.nl"
#        server = "https://acme-v02.api.letsencrypt.org/directory"
#        disableAccountKeyGeneration = true
#        privateKeySecretRef = {
#          name = "rowland-issuer-account-key"
#        }
#        solvers = [
#          {
#            "dns01" = local.cloudflare-dns-solver
#          }
#        ]
#      }
#    }
#  }
#}