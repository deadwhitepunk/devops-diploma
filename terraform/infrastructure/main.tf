module "workers" {
  source             = "./modules/vm-module"
  for_each           = var.workers
  name               = each.key
  hostname           = each.key
  disk_size          = each.value.disk_size
  platform_id        = var.platform_id
  zone               = each.value.zone
  ram                = each.value.ram
  cpu                = each.value.cpu
  subnet_id          = yandex_vpc_subnet.subnets[each.value.subnet_id].id
  ssh_public_key     = var.ssh_public_key
  image_id           = var.image_id
  public_ip          = false
  preemptible        = true
  security_group_ids = toset([yandex_vpc_security_group.workers_sg.id])
}

module "control_planes" {
  source             = "./modules/vm-module"
  for_each           = var.control_planes
  name               = each.key
  hostname           = each.key
  disk_size          = each.value.disk_size
  platform_id        = var.platform_id
  zone               = each.value.zone
  ram                = each.value.ram
  cpu                = each.value.cpu
  subnet_id          = yandex_vpc_subnet.subnets[each.value.subnet_id].id
  ssh_public_key     = var.ssh_public_key
  image_id           = var.image_id
  public_ip          = false
  preemptible        = false
  security_group_ids = toset([yandex_vpc_security_group.control_plane_sg.id])
}

module "bastion" {
  source             = "./modules/vm-module"
  name               = "bastion"
  hostname           = "bastion"
  disk_size          = var.bastion.disk_size
  platform_id        = var.platform_id
  zone               = var.bastion.zone
  ram                = var.bastion.ram
  cpu                = var.bastion.cpu
  subnet_id          = yandex_vpc_subnet.subnets[var.bastion.subnet_id].id
  ssh_public_key     = var.ssh_public_key
  image_id           = var.image_id
  public_ip          = true
  preemptible        = false
  security_group_ids = toset([yandex_vpc_security_group.bastion_sg.id])
}