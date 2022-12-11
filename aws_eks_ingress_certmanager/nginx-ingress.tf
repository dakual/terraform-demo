resource "kubernetes_namespace" "nginx" {
  metadata {
    labels = {
      name = "ingress-nginx"
    }
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_nginx" {
  name              = "ingress-nginx"
  repository        = "https://kubernetes.github.io/ingress-nginx"
  chart             = "ingress-nginx"
  namespace         = local.namespace
  version           = "4.4.0"
  create_namespace  = false
  timeout           = 300

  values = [
    "${file("${path.module}/files/nginx_ingress.yml")}"
  ]

  depends_on = [
    kubernetes_namespace.nginx
  ]
}