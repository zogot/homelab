#resource "kubernetes_namespace" "metallb-system" {
#  depends_on = [local_file.kube-config]
#
#  metadata {
#    name = "metallb-system"
#
#    labels = {
#      "pod-security.kubernetes.io/enforce" = "privileged"
#      "pod-security.kubernetes.io/audit" = "privileged"
#      "pod-security.kubernetes.io/warn"  = "privileged"
#    }
#  }
#}
#
#resource "helm_release" "metallb" {
#  depends_on = [kubernetes_namespace.metallb-system]
#
#  chart = "metallb"
#  name  = "metallb"
#  repository = "https://metallb.github.io/metallb"
#  namespace = "metallb-system"
#}
#
#resource "helm_release" "metallb-config" {
#  name = "metallb-config"
#  chart = "../helm/metallb"
#  depends_on = [helm_release.metallb]
#  namespace = "metallb-system"
#}