data "cloudflare_zone" "redacreltd" {
  name = "kruta.link"
}

resource "cloudflare_record" "grafana" {
  zone_id = data.cloudflare_zone.this.id
  name    = "m1"
  value   = "127.0.0.1"
  type    = "CNAME"
  ttl     = 3600
}