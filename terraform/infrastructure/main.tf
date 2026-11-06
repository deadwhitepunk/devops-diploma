module "workers" {
  source         = "./modules/vm-module"
  for_each       = var.workers
  name           = each.key
  hostname       = each.key
  disk_size      = each.value.disk_size
  platform_id    = var.platform_id
  zone           = each.value.zone
  ram            = each.value.ram
  cpu            = each.value.cpu
  subnet_id      = each.value.subnet_id
  ssh_public_key = var.ssh_public_key
  image_id       = var.image_id
  public_ip      = false
  preemptible    = true
}

module "control_planes" {
  source         = "./modules/vm-module"
  for_each       = var.control_planes
  name           = each.key
  hostname       = each.key
  disk_size      = each.value.disk_size
  platform_id    = var.platform_id
  zone           = each.value.zone
  ram            = each.value.ram
  cpu            = each.value.cpu
  subnet_id      = each.value.subnet_id
  ssh_public_key = var.ssh_public_key
  image_id       = var.image_id
  public_ip      = false
  preemptible    = false
}

module "bastion" {
  source         = "./modules/vm-module"
  name           = "bastion"
  hostname       = "bastion"
  disk_size      = var.bastion.disk_size
  platform_id    = var.platform_id
  zone           = var.bastion.zone
  ram            = var.bastion.ram
  cpu            = var.bastion.cpu
  subnet_id      = var.bastion.subnet_id
  ssh_public_key = var.ssh_public_key
  image_id       = var.image_id
  public_ip      = true
  preemptible    = false
}