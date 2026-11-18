resource "yandex_dns_zone" "zone1" {
  name        = "devops-diploma"
  description = "Public dns zone for diploma"

  labels = {
    label1 = "label"
  }

  zone   = "systemerase.site."
  public = true
}

resource "yandex_dns_recordset" "app" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "app.systemerase.site."
  type    = "A"
  ttl     = 300

  data = [
    yandex_alb_load_balancer.diploma_alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
  ]
}

resource "yandex_dns_recordset" "grafana" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "grafana.systemerase.site."
  type    = "A"
  ttl     = 300

  data = [
    yandex_alb_load_balancer.diploma_alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
  ]
}
