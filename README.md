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

```sh
Plan: 13 to add, 0 to change, 0 to destroy.
yandex_vpc_network.vpc: Creating...
yandex_vpc_gateway.nat_gateway: Creating...
yandex_vpc_gateway.nat_gateway: Creation complete after 1s [id=enpkq1g64gcsrki8496s]
yandex_vpc_network.vpc: Creation complete after 2s [id=enpieb7rupsnkj1t4em4]
yandex_vpc_route_table.private_rt: Creating...
yandex_vpc_security_group.bastion_sg: Creating...
yandex_vpc_security_group.control_plane_sg: Creating...
yandex_vpc_security_group.workers_sg: Creating...
yandex_vpc_route_table.private_rt: Creation complete after 1s [id=enp6pabetmjbvl6jftfj]
yandex_vpc_subnet.subnets["private-a"]: Creating...
yandex_vpc_subnet.subnets["public-a"]: Creating...
yandex_vpc_subnet.subnets["private-d"]: Creating...
yandex_vpc_subnet.subnets["private-d"]: Creation complete after 1s [id=fl8406mp7d8m6oio2763]
yandex_vpc_subnet.subnets["private-a"]: Creation complete after 1s [id=e9bppnsh08dqthgef3cd]
yandex_vpc_subnet.subnets["public-a"]: Creation complete after 1s [id=e9bqthssqrep1fjk2l62]
yandex_vpc_security_group.workers_sg: Creation complete after 2s [id=enp6eedc50rem7tn13oe]
module.workers["worker-01"].yandex_compute_instance.vm: Creating...
module.workers["worker-02"].yandex_compute_instance.vm: Creating...
yandex_vpc_security_group.bastion_sg: Creation complete after 4s [id=enp7sgaffukp05dr86m2]
module.bastion.yandex_compute_instance.vm: Creating...
yandex_vpc_security_group.control_plane_sg: Creation complete after 6s [id=enpm8loqdrujpvjbjegq]
module.control_planes["control-plane-01"].yandex_compute_instance.vm: Creating...
module.workers["worker-02"].yandex_compute_instance.vm: Still creating... [00m10s elapsed]
module.workers["worker-01"].yandex_compute_instance.vm: Still creating... [00m10s elapsed]
module.bastion.yandex_compute_instance.vm: Still creating... [00m10s elapsed]
module.control_planes["control-plane-01"].yandex_compute_instance.vm: Still creating... [00m10s elapsed]
module.workers["worker-02"].yandex_compute_instance.vm: Still creating... [00m20s elapsed]
module.workers["worker-01"].yandex_compute_instance.vm: Still creating... [00m20s elapsed]
module.bastion.yandex_compute_instance.vm: Still creating... [00m20s elapsed]
module.control_planes["control-plane-01"].yandex_compute_instance.vm: Still creating... [00m20s elapsed]
module.workers["worker-01"].yandex_compute_instance.vm: Still creating... [00m30s elapsed]
module.workers["worker-02"].yandex_compute_instance.vm: Still creating... [00m30s elapsed]
module.bastion.yandex_compute_instance.vm: Still creating... [00m30s elapsed]
module.control_planes["control-plane-01"].yandex_compute_instance.vm: Still creating... [00m30s elapsed]
module.workers["worker-01"].yandex_compute_instance.vm: Creation complete after 36s [id=fhmgo1k3i3eja5g1n168]
module.control_planes["control-plane-01"].yandex_compute_instance.vm: Creation complete after 33s [id=fhm9t2barvkvqu1ghc1h]
module.workers["worker-02"].yandex_compute_instance.vm: Still creating... [00m40s elapsed]
module.bastion.yandex_compute_instance.vm: Still creating... [00m40s elapsed]
module.workers["worker-02"].yandex_compute_instance.vm: Creation complete after 49s [id=fv4hob6lh4qaii79aiib]
module.bastion.yandex_compute_instance.vm: Creation complete after 49s [id=fhmq3fred62quv9si6od]
```
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Настройка SSHJump через Bastion-host

Заполняем ~/.ssh/config

```sh
Host bastion-jump
  Hostname 51.250.64.201
  User ubuntu
Host control-plane-01
  HostName 10.10.2.18
  User ubuntu
  ProxyJump bastion-jump
Host worker-01
  HostName 10.10.2.22     
  User ubuntu
  ProxyJump bastion-jump
Host worker-02
  HostName 10.10.3.9     
  User ubuntu
  ProxyJump bastion-jump
```

Проверяем:

`ssh -l ubuntu worker-01`

```sh
 System information as of Thu Nov 12 06:14:18 UTC 2026

  System load:  0.09               Processes:             106
  Usage of /:   13.4% of 18.75GB   Users logged in:       0
  Memory usage: 6%                 IPv4 address for eth0: 10.10.2.22
  Swap usage:   0%

ubuntu@worker-01:~$ 
```
Успех

4. Ansible

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