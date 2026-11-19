
resource "yandex_vpc_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Security group for Jenkins"
  network_id  = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "TCP"
    description    = "SSH from Bastion subnet"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Jenkins HTTP from ALB"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 8080
  }

  egress {
    protocol       = "TCP"
    description    = "Internet HTTPS and HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 80
    to_port        = 443
  }

  egress {
    protocol       = "TCP"
    description    = "Kubernetes API"
    v4_cidr_blocks = ["10.10.2.0/24"]
    port           = 6443
  }

  egress {
    protocol       = "UDP"
    description    = "DNS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 53
  }

  egress {
    protocol       = "TCP"
    description    = "DNS TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 53
  }

  egress {
    protocol       = "UDP"
    description    = "NTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 123
  }
}

module "jenkins" {
  source             = "./modules/vm-module"
  name               = "jenkins"
  hostname           = "jenkins"
  disk_size          = 20
  platform_id        = var.platform_id
  zone               = "ru-central1-a"
  ram                = 4
  cpu                = 2
  subnet_id          = yandex_vpc_subnet.subnets["private-a"].id
  ssh_public_key     = var.ssh_public_key
  image_id           = var.image_id
  public_ip          = false
  preemptible        = false
  security_group_ids = toset([yandex_vpc_security_group.jenkins_sg.id])

  user_data = <<-EOF
  #cloud-config
  package_update: true

  packages:
    - docker.io

  runcmd:
    - systemctl enable --now docker
    - docker volume create jenkins_home
    - docker run -d
        --name jenkins
        --restart unless-stopped
        -p 8080:8080
        -p 50000:50000
        -v jenkins_home:/var/jenkins_home
        jenkins/jenkins:lts-jdk21
EOF
}

resource "yandex_alb_target_group" "jenkins_tg" {
  name = "jenkins-target-group"

  target {
    subnet_id  = yandex_vpc_subnet.subnets["private-a"].id
    ip_address = module.jenkins.private_ip
  }
}

resource "yandex_alb_backend_group" "jenkins_bg" {
  name = "jenkins-backend"

  http_backend {
    name             = "jenkins-backend"
    weight           = 1
    port             = 8080
    target_group_ids = [yandex_alb_target_group.jenkins_tg.id]

    healthcheck {
      timeout  = "5s"
      interval = "10s"

      http_healthcheck {
        path = "/login"
      }
    }
  }
}

resource "yandex_alb_virtual_host" "jenkins_vhost" {
  name           = "jenkins-vhost"
  http_router_id = yandex_alb_http_router.router.id
  authority      = ["jenkins.systemerase.site"]

  route {
    name = "jenkins-route"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.jenkins_bg.id
        timeout          = "10s"
      }
    }
  }
}

resource "yandex_dns_recordset" "jenkins" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "jenkins.systemerase.site."
  type    = "A"
  ttl     = 300

  data = [
    yandex_alb_load_balancer.diploma_alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
  ]
}

output "jenkins_private_ip" {
  value = module.jenkins.private_ip
}
