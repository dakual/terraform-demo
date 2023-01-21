resource "helm_release" "grafana" {
  chart         = "grafana"
  name          = "grafana"
  repository    = "https://grafana.github.io/helm-charts"
  namespace     = kubernetes_namespace.monitoring.metadata.0.name
  version       = "6.44.9"
  wait          = true
  wait_for_jobs = true

  values = [
    templatefile("${path.module}/configs/grafana.yaml", {
      prometheus_svc = "${helm_release.prometheus.name}-server"
    })
  ]

  depends_on = [
    helm_release.prometheus
  ]
}
