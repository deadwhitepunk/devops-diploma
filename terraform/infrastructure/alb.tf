resource "yandex_alb_target_group" "target_group" {
  name = "diploma-target-group"

  target {
    subnet_id  = yandex_vpc_subnet.subnets["private-a"].id
    ip_address = module.workers["worker-01"].private_ip
  }

  target {
    subnet_id  = yandex_vpc_subnet.subnets["private-d"].id
    ip_address = module.workers["worker-02"].private_ip
  }
}

resource "yandex_alb_backend_group" "app_bg" {
  name = "app-backend"

  http_backend {
    name             = "app-backend"
    weight           = 1
    port             = 31235
    target_group_ids = [yandex_alb_target_group.target_group.id]
    healthcheck {
      timeout  = "1s"
      interval = "5s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_backend_group" "grafana_bg" {
  name = "grafana-backend"

  http_backend {
    name             = "grafana-backend"
    weight           = 1
    port             = 31000
    target_group_ids = [yandex_alb_target_group.target_group.id]
    healthcheck {
      timeout  = "1s"
      interval = "5s"
      http_healthcheck {
        path = "/api/health"
      }
    }
  }
}

resource "yandex_alb_http_router" "router" {
  name = "http-router"
}

resource "yandex_alb_virtual_host" "app_vhost" {
  name           = "app-vhost"
  http_router_id = yandex_alb_http_router.router.id
  authority      = ["app.systemerase.site"]
  route {
    name = "app-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.app_bg.id
        timeout          = "3s"
      }
    }
  }
}

resource "yandex_alb_virtual_host" "grafana_vhost" {
  name           = "grafana-vhost"
  http_router_id = yandex_alb_http_router.router.id
  authority      = ["grafana.systemerase.site"]
  route {
    name = "grafana-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.grafana_bg.id
        timeout          = "3s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "diploma_alb" {
  name               = "diploma-alb"
  security_group_ids = [yandex_vpc_security_group.alb_sg.id]
  network_id         = yandex_vpc_network.vpc.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnets["public-a"].id
    }
  }

  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.router.id
      }
    }
  }
}


