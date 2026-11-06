resource "yandex_compute_instance" "vm" {
  name        = var.name
  hostname    = var.hostname
  platform_id = var.platform_id
  zone        = var.zone

  resources {
    cores  = var.cpu
    memory = var.ram
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk_size
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = var.public_ip
  }
  scheduling_policy {
    preemptible = var.preemptible
  }
  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}