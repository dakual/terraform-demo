resource "helm_release" "prometheus" {
  chart         = "prometheus"
  name          = "prometheus"
  namespace     = kubernetes_namespace.monitoring.metadata.0.name
  repository    = "https://prometheus-community.github.io/helm-charts"
  version       = "18.1.0"
  wait          = true
  wait_for_jobs = true

  values = [
    templatefile("${path.module}/configs/prometheus.yml", {
      persistence_volume    = true
    }),
    file("${path.module}/configs/alertmanager.yml"),
    file("${path.module}/configs/alerting_rules.yml")
  ]
 
  depends_on = [
    kubernetes_namespace.monitoring,
  ]
}