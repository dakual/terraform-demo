data "aws_lb" "ingress" {
  tags = local.ingress_load_balancer_tags

  depends_on = [
    helm_release.ingress_nginx
  ]
}

data "aws_route53_zone" "primary" {
  name = local.domain
}

resource "aws_route53_record" "ingress_alias" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = data.aws_route53_zone.primary.name
  type    = "A"

  alias {
    name                   = data.aws_lb.ingress.dns_name
    zone_id                = data.aws_lb.ingress.zone_id
    evaluate_target_health = true
  }
}
