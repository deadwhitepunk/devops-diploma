resource "yandex_dns_zone" "zone1" {
  name        = "devops-diploma"
  description = "Public dns zone for diploma"

  labels = {
    label1 = "label"
  }

  zone   = "systemerase.site."
  public = true
}
