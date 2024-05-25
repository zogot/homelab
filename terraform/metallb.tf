#resource "kubernetes_namespace" "metallb-config-system" {
#  depends_on = [local_file.kube-config]
#
#  metadata {
#    name = "metallb-config-system"
#
#    labels = {
#      "pod-security.kubernetes.io/enforce" = "privileged"
#      "pod-security.kubernetes.io/audit" = "privileged"
#      "pod-security.kubernetes.io/warn"  = "privileged"
#    }
#  }
#}
#
#resource "helm_release" "metallb-config" {
#  depends_on = [kubernetes_namespace.metallb-config-system]
#
#  chart = "metallb-config"
#  name  = "metallb-config"
#  repository = "https://metallb.github.io/metallb"
#  namespace = "metallb-config-system"
#}
#
#resource "helm_release" "metallb-config-config" {
#  name = "metallb-config-config"
#  chart = "../helm/metallb-config"
#  depends_on = [helm_release.metallb-config]
#  namespace = "metallb-config-system"
#}