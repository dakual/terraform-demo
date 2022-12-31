data "kubernetes_service_v1" "ingress" {
  metadata {
    name      = local.var.ingress.service
    namespace = local.var.ingress.namespace
  }
}

data "aws_route53_zone" "primary" {
  name = local.var.domain
}

resource "aws_route53_record" "prometheus" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = local.var.prometheus.cname
  type    = "CNAME"
  ttl     = 5

  records = [data.kubernetes_service_v1.ingress.status.0.load_balancer.0.ingress.0.hostname]
}

resource "aws_route53_record" "grafana" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = local.var.grafana.cname
  type    = "CNAME"
  ttl     = 5

  records = [data.kubernetes_service_v1.ingress.status.0.load_balancer.0.ingress.0.hostname]
}