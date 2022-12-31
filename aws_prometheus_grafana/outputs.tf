output "grafana-url" {
  value = ""
}

output "prometheus-url" {
  value = ""
}

output "nginx-ingress-internal" {
  value = "data.kubernetes_service_v1.ingress_internal.status.0.load_balancer.0.ingress.0.hostname"
}

output "grafana_username" {
  value     = local.var.grafana.admin_username
}

output "grafana_password" {
  value     = nonsensitive(random_password.grafana.result)
  sensitive = false
}

output "prometheus_username" {
  value     = local.var.prometheus.admin_username
}

output "prometheus_password" {
  value     = nonsensitive(random_password.prometheus.result)
  sensitive = false
}