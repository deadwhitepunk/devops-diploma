variable "name" {
  description = "Name of virtual machine"
  type        = string
}

variable "hostname" {
  description = "Name inside OS"
  type        = string
}

variable "image_id" {
  description = "ID of image for OS"
  type        = string
}

variable "cpu" {
  description = "Number of vCPU on host"
  type        = number

  validation {
    condition     = var.cpu > 0
    error_message = "CPU must be grater then 0"
  }
}

variable "ram" {
  description = "Amount of RAM in GB"
  type        = number

  validation {
    condition     = var.ram > 0
    error_message = "RAM must be grater then 0"
  }
}

variable "disk_size" {
  description = "Size of disk"
  type        = number
}

variable "disk_type" {
  description = "ssd/hdd"
  type        = string
  default     = "network-ssd"

  validation {
    condition = contains(
      ["network-ssd", "network-hdd", "network-ssd-nonreplicated"], var.disk_type
    )
    error_message = "Unsupported disk type"
  }
}

variable "platform_id" {
  description = "Platform in YC"
  type        = string
}

variable "zone" {
  description = "Zone of allocation in YC"
  type        = string
}

variable "subnet_id" {
  description = "id of subnet"
  type        = string
}

variable "public_ip" {
  description = "Public ip yes/no"
  type        = bool
  default     = false
}

variable "preemptible" {
  description = "Preemptible vm or not?"
  type        = bool
  default     = false
}

variable "ssh_public_key" {
  description = "Public SSH key for VM access"
  type        = string
}