resource "kubernetes_ingress_v1" "ingress" {
  wait_for_load_balancer = true

  metadata {
    name        = "app-ingress"
    namespace   = local.namespace
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
      "cert-manager.io/cluster-issuer"             = "letsencrypt-staging"
    }
  }

  spec {
    ingress_class_name = "nginx"
    default_backend {
      service {
        name = "app-01"
        port {
          number = 80
        }
      }
    }

    tls {
      hosts = [
        local.domain
      ]
      secret_name = local.domain
    }

    rule {
      host = local.domain
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "app-01"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.ingress_nginx,
    helm_release.cert_manager
  ]
}