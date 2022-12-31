resource "random_password" "grafana" {
  length = 24
}

resource "kubernetes_secret" "grafana" {
  metadata {
    name      = "grafana-auth"
    namespace = kubernetes_namespace.monitoring.metadata.0.name
  }

  data = {
    admin-user     = local.var.grafana.admin_username
    admin-password = random_password.grafana.result
  }
}

resource "helm_release" "grafana" {
  chart         = "grafana"
  name          = "grafana"
  repository    = "https://grafana.github.io/helm-charts"
  namespace     = kubernetes_namespace.monitoring.metadata.0.name
  version       = "6.48.0"
  wait          = true
  wait_for_jobs = true

  values = [
    templatefile("${path.module}/configs/grafana.yaml", {
      admin_existing_secret = kubernetes_secret.grafana.metadata[0].name
      admin_user_key        = "admin-user"
      admin_password_key    = "admin-password"
      prometheus_svc        = "${helm_release.prometheus.name}-server"
      hosts                 = "[${local.var.grafana.cname}.${local.var.domain}]"
    })
  ]

  depends_on = [
    helm_release.prometheus,
    aws_eks_addon.ebs-csi
  ]
}
