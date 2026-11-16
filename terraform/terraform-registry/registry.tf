resource "yandex_container_registry" "diploma" {
  name = "diploma-project"
}

resource "yandex_container_repository" "app" {
  name = "${yandex_container_registry.diploma.id}/app-repository"
}