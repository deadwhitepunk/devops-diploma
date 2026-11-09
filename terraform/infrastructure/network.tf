resource "yandex_vpc_network" "vpc" {
  name = "project_vpc"
}

resource "yandex_vpc_subnet" "subnets" {
  for_each       = var.subnets
  name           = each.key
  v4_cidr_blocks = [each.value.cidr]
  zone           = each.value.zone
  network_id     = yandex_vpc_network.vpc.id
  route_table_id = each.key == "private-a" || each.key == "private-b" ? yandex_vpc_route_table.private_rt.id : null
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "project-nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private_rt" {
  network_id = yandex_vpc_network.vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}