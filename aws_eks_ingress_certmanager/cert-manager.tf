resource "kubernetes_namespace" "cert_manager" {
  metadata {
    labels = {
      name = "cert-manager"
    }
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = "1.10.1"
  namespace  = kubernetes_namespace.cert_manager.id

  set {
    name  = "installCRDs"
    value = true
  }

  values = [
    "${file("${path.module}/files/cert_manager.yml")}"
  ]

  depends_on = [
    kubernetes_namespace.cert_manager
  ]
}

data "kubectl_path_documents" "k8s_issuer" {
  pattern = "${path.module}/k8s-issuer/*.yml"
}

resource "kubectl_manifest" "k8s_issuer" {
  for_each  = toset(data.kubectl_path_documents.k8s_issuer.documents)
  yaml_body = each.value

  depends_on = [
    helm_release.cert_manager
  ]
}

# resource "kubernetes_manifest" "letsencrypt_staging" {
#   manifest = yamldecode(templatefile(
#     "${path.module}/files/letsencrypt-issuer.tpl.yml",
#     {
#       "name"          = "letsencrypt-staging"
#       "email"         = "daghan.altunsoy@gmail.com"
#       "server"        = "https://acme-staging-v02.api.letsencrypt.org/directory"
#       "ingress_class" = "nginx"
#     }
#   ))

#   depends_on = [
#     helm_release.cert_manager
#   ]
# }

# resource "kubernetes_manifest" "letsencrypt_production" {
#   manifest = yamldecode(templatefile(
#     "${path.module}/files/letsencrypt-issuer.tpl.yml",
#     {
#       "name"          = "letsencrypt-production"
#       "email"         = "daghan.altunsoy@gmail.com"
#       "server"        = "https://acme-v02.api.letsencrypt.org/directory"
#       "ingress_class" = "nginx"
#     }
#   ))

#   depends_on = [
#     helm_release.cert_manager
#   ]
# }