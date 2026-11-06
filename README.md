## DevOps Diploma Project Netology YC
## Zhelonkin Dmitrii

#### О проекте

Проект создается в рамках обучения по курсу по направлению DevOps

Цель проекта - развернуть облачную инфраструктуру в YandexCloud, установить Kubernetes, настроить мониторинг и реализовать автоматизированные процессы CI/CD для тест приложения

#### Архитектура проекта

Для реализации дипломного проекта была выбрана следующая архитектура:

Cloud provider: Yandex cloud
IaC: Terraform
IaC configuration: Ansible
K8S deployment: SelfHost Kubernetes на базе Ubuntu 26.04 LTS с использованием KubeSpray
Monitoring: Prometheus, Grafana, Alertmanager
CI/CD: будет определено на следующих этапах проекта
Container Registry: будет определён на следующих этапах проекта

#### Архитектурные решения

Конфигурация кластера:

Control plane - 1

Worker node - 2

Установка и настройка Kubernetes будут выполняться с помощью Kubespray, управление конфигурацией — через Ansible.

2. Сетевая инфраструктура

Планируется создать VPC с подсетями в нескольких зонах доступности Yandex Cloud.

Для административного доступа будет использоваться отдельная виртуальная машина Bastion Host.

Предполагаемая схема доступа:

Bastion Host — публичный IP-адрес.

Control Plane — только приватный IP-адрес.

Worker Nodes — только приватные IP-адреса.

Администрирование внутренних узлов — через Bastion Host.

Внешняя публикация приложений — через Ingress Controller и внешний Load Balancer (требует отдельной настройки).

3. Terraform

Terraform будет использоваться для автоматического создания облачной инфраструктуры.

Планируемые ресурсы:

VPC и подсети в разных зонах доступности.

Security Groups.

Виртуальные машины Control Plane и Worker Nodes.

Bastion Host.

Необходимые сетевые компоненты.

Для повторного использования конфигурации будет разработан универсальный Terraform-модуль виртуальной машины.

Для управления состоянием Terraform планируется использовать Yandex Object Storage (Remote Backend).

1. Схема инфраструктуры
Вся инфраструктура будет написана в terraform
Kubernetes:
3 виртулаки под одной VPC в разных зонах доступности
После того, как terraform создаст виртуальные машины их внешние айпи адреса будут переданы ansible где под капотом будет KubeSpray
Будет отдельный бакет
Стейт терраформа зашифрованный в отделом бакете
Сервисный аккаунт будет создан руками в yandex cloud

2. Terraform - развертывание инфраструктуры в Yandex Cloud
Cloud	Yandex Cloud
IaC	Terraform
Kubernetes	Self-hosted
Control Plane	1 VM
Worker Nodes	2 VM
Provisioning	Terraform
Configuration Management	Ansible + Kubespray
Network	VPC + подсети в разных AZ
Terraform State	Yandex Object Storage
Worker VM	Preemptible