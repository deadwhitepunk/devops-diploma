resource "yandex_vpc_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Security group for SG"
  network_id  = yandex_vpc_network.vpc.id

  labels = {
    type = "bastion"
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["46.48.76.123/32"]
    port           = 22
  }

  egress {
    protocol       = "TCP"
    description    = "SSH to Control nodes"
    v4_cidr_blocks = ["10.10.2.0/24", "10.10.3.0/24"]
    from_port      = 22
    to_port        = 22
  }

  egress {
    protocol       = "TCP"
    description    = "Use kubectl on bastion"
    v4_cidr_blocks = ["10.10.2.0/24"]
    from_port      = 6443
    to_port        = 6443
  }

  egress {
    protocol       = "UDP"
    description    = "DNS UDP"
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

resource "yandex_vpc_security_group" "control_plane_sg" {
  name        = "control_plane_sg"
  description = "Security group for control plane"
  network_id  = yandex_vpc_network.vpc.id

  labels = {
    stage = "kuber"
    type  = "control_plane"
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Kubernetes API"
    v4_cidr_blocks = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
    port           = 6443
  }

  ingress {
    protocol       = "UDP"
    description    = "Flannel VXLAN"
    v4_cidr_blocks = ["10.10.2.0/24", "10.10.3.0/24"]
    port           = 8472
  }

  ingress {
    protocol       = "UDP"
    description    = "Calico VXLAN traffic from Kubernetes nodes"
    v4_cidr_blocks = ["10.10.2.0/24", "10.10.3.0/24"]
    port           = 4789
  }

  egress {
    protocol       = "TCP"
    description    = "kubelet"
    v4_cidr_blocks = ["10.10.2.0/24", "10.10.3.0/24"]
    from_port      = 10250
    to_port        = 10250
  }

  egress {
    protocol       = "UDP"
    description    = "Calico VXLAN traffic to Kubernetes nodes"
    v4_cidr_blocks = ["10.10.2.0/24", "10.10.3.0/24"]
    port           = 4789
  }

  egress {
    protocol       = "UDP"
    description    = "Flannel VXLAN"
    v4_cidr_blocks = ["10.10.2.0/24", "10.10.3.0/24"]
    from_port      = 8472
    to_port        = 8472
  }

  egress {
    protocol       = "TCP"
    description    = "For registry + ubuntu repos"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 80
    to_port        = 80
  }

  egress {
    protocol       = "TCP"
    description    = "For registry + ubuntu repos"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 443
    to_port        = 443
  }

  egress {
    protocol       = "UDP"
    description    = "DNS UDP"
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

  egress {
    protocol       = "TCP"
    description    = "Kubernetes NodePort to worker nodes"
    v4_cidr_blocks = ["10.10.2.0/24", "10.10.3.0/24"]
    from_port      = 30000
    to_port        = 32767
  }
}

resource "yandex_vpc_security_group" "workers_sg" {
  name        = "workers_sg"
  description = "Security group for worker nodes"
  network_id  = yandex_vpc_network.vpc.id

  labels = {
    stage = "kuber"
    type  = "worker_nodes"
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "kubelet"
    v4_cidr_blocks = ["10.10.2.0/24"]
    port           = 10250
  }

  ingress {
    protocol       = "UDP"
    description    = "Flannel VXLAN"
    v4_cidr_blocks = ["10.10.2.0/24", "10.10.3.0/24"]
    port           = 8472
  }

  ingress {
    protocol       = "UDP"
    description    = "Calico VXLAN traffic between Kubernetes nodes"
    v4_cidr_blocks = ["10.10.2.0/24", "10.10.3.0/24"]
    port           = 4789
  }

  ingress {
    protocol       = "TCP"
    description    = "Kubernetes NodePort from control-plane"
    v4_cidr_blocks = ["10.10.2.0/24", "10.10.3.0/24"]
    from_port      = 30000
    to_port        = 32767
  }

  ingress {
    protocol       = "TCP"
    description    = "Grafana from ALB"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 31000
  }

  ingress {
    protocol       = "TCP"
    description    = "Application from ALB"
    v4_cidr_blocks = ["10.10.1.0/24"]
    port           = 31235
  }

  egress {
    protocol       = "TCP"
    description    = "For registry + ubuntu repos"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 80
    to_port        = 80
  }

  egress {
    protocol       = "TCP"
    description    = "For registry + ubuntu repos"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 443
    to_port        = 443
  }

  egress {
    protocol       = "UDP"
    description    = "Flannel VXLAN"
    v4_cidr_blocks = ["10.10.2.0/24", "10.10.3.0/24"]
    from_port      = 8472
    to_port        = 8472
  }

  egress {
    protocol       = "TCP"
    description    = "Kube API to control plane"
    v4_cidr_blocks = ["10.10.2.0/24"]
    from_port      = 6443
    to_port        = 6443
  }

  egress {
    protocol       = "UDP"
    description    = "DNS UDP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 53
  }

  egress {
    protocol       = "UDP"
    description    = "Calico VXLAN traffic between Kubernetes nodes"
    v4_cidr_blocks = ["10.10.2.0/24", "10.10.3.0/24"]
    port           = 4789
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

resource "yandex_vpc_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Security group for Application Load Balancer"
  network_id  = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "TCP"
    description    = "Public HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  egress {
  protocol       = "ANY"
  description    = "Traffic to backend workers"
  v4_cidr_blocks = ["10.10.2.0/24", "10.10.3.0/24"]
  from_port      = 0
  to_port        = 65535
}
}