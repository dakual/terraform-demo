resource "random_password" "prometheus" {
  length = 24
}

resource "kubernetes_secret" "prometheus" {
  metadata {
    name      = "prometheus-auth"
    namespace = kubernetes_namespace.monitoring.metadata.0.name
  }

  data = {
    "auth" : "${local.var.prometheus.admin_username}:${bcrypt(random_password.prometheus.result)}"
  }
}


resource "helm_release" "prometheus" {
  chart         = "prometheus"
  name          = "prometheus"
  namespace     = kubernetes_namespace.monitoring.metadata.0.name
  repository    = "https://prometheus-community.github.io/helm-charts"
  version       = "19.1.0"
  wait          = true
  wait_for_jobs = true

  values = [
    templatefile("${path.module}/configs/prometheus.yml", {
      hosts = "[${local.var.prometheus.cname}.${local.var.domain}]"
    }),
    file("${path.module}/configs/alertmanager.yml"),
    file("${path.module}/configs/alerting_rules.yml")
  ]
 
  depends_on = [
    kubernetes_namespace.monitoring,
    aws_eks_addon.ebs-csi
  ]
}