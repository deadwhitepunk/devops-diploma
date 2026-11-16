terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 1.6.3"
}

provider "yandex" {
  zone      = "ru-central1-a"
  folder_id = "b1gs2kftghrh9vu74phs"
} 