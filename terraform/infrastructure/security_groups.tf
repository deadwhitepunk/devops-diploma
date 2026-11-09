resource "yandex_vpc_security_group" "bastion_sg" {
  name        = "bastion sg"
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
}

resource "yandex_vpc_security_group" "control_plane_sg" {
  name        = "control plane sg"
  description = "Security group for control plane"
  network_id  = yandex_vpc_network.vpc.id

  labels = {
    stage = "kuber"
    type  = "control plane"
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

  egress {
    protocol       = "TCP"
    description    = "kubelet"
    v4_cidr_blocks = ["10.10.2.0/24", "10.10.3.0/24"]
    from_port      = 10250
    to_port        = 10250
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
}

resource "yandex_vpc_security_group" "workers_sg" {
  name        = "workers sg"
  description = "Security group for worker nodes"
  network_id  = yandex_vpc_network.vpc.id

  labels = {
    stage = "kuber"
    type  = "worker nodes"
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
}