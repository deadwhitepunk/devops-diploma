variable "folder_id" {
  description = "(Optional) - Yandex Cloud Folder ID where resources will be created."
  type        = string
  default     = "b1gs2kftghrh9vu74phs"
}

variable "cloud_id" {
  type    = string
  default = "b1gj4267eqa8nhcdjka9"
}

variable "image_id" {
  description = "(Optional) - Boot disk image id. If not provided, it defaults to Ubuntu 22.04 LTS image id"
  type        = string
  default     = "fd833v6c5tb0udvk4jo6"
}

variable "network_id" {
  description = "Network id"
  type        = string
  default     = "enppppq3vsmqg9n4ljet"
}

variable "workers" {
  description = "Worker nodes configuration"

  type = map(object({
    cpu       = number
    ram       = number
    disk_size = number
    zone      = string
    subnet_id = string
  }))
}

variable "control_planes" {
  description = "Control plane nodes configuration"

  type = map(object({
    cpu       = number
    ram       = number
    disk_size = number
    zone      = string
    subnet_id = string
  }))
}

variable "bastion" {
  description = "Bastion for connection"

  type = object({
    cpu       = number
    ram       = number
    disk_size = number
    zone      = string
    subnet_id = string
  })
}

variable "ssh_public_key" {
  description = "Public SSH key for infrastructure access"
  type        = string
}

variable "platform_id" {
  description = "Name of platform"
  type        = string
  default     = "standard-v3"
}