## диплом netology - отказоустойчивая инфраструктура для сайта в yandex cloud
terraform - инфраструктура, ansible - настройка софта на vm

репозиторий: terraform/ (код) + img/ (скрины)

## содержание

- 0 требования и договорённости
- 1 сеть и подсети
- 2 nat и маршрутизация private
- 3 terraform outputs

## 0 требования и договорённости

важное

- ключи и токены yandex cloud в git не выкладываю
- в ansible inventory не использую ip, только fqdn вида *.ru-central1.internal
- web vm без публичных ip, ssh только через bastion
- сайт доступен только через application load balancer
- monitoring: zabbix + agents, дашборды по принципу use + пороги
- logs: elasticsearch + kibana + filebeat (nginx access.log и error.log)
- backups: snapshots ежедневно, хранение 7 дней

практика для диплома

- vm планируются минимальные (2 vcpu, 2-4 gb ram, 10 gb disk), можно прерываемые
- перед отправкой на проверку прерываемые vm переводятся в обычные, чтобы не отвалились через 24 часа

## 0.1 текущий прогресс

- [X] сеть vpc + подсети
- [X] nat gateway + route table для private подсетей
- [X] security groups
- [X] bastion vm
- [ ] web vm x2 + alb
- [ ] zabbix + agents
- [ ] elastic + kibana + filebeat
- [ ] snapshots schedule

---

## 1 сеть и подсети

создан vpc `sys-diplom` и 3 подсети

- public (ru-central1-a)
- private-a (ru-central1-a)
- private-b (ru-central1-b)

где смотреть в консоли
vpc -> сети -> sys-diplom

![vpc subnets](img/01-vpc-subnets.png)

---

## 2 nat и маршрутизация private

для private подсетей настроен исходящий доступ в интернет через nat gateway
создана route table с маршрутом `0.0.0.0/0` через nat и привязана к private-a и private-b

где смотреть в консоли

- vpc -> шлюзы -> sys-diplom-nat
- vpc -> таблицы маршрутизации -> sys-diplom-private-rt
- vpc -> подсети -> sys-diplom-private-a / sys-diplom-private-b (поле таблица маршрутизации)

![nat gateway](img/02-nat-gateway.png)
![route table](img/03-route-table.png)
![private a rt](img/04-private-a-rt.png)
![private b rt](img/05-private-b-rt.png)

---

## 3 terraform outputs

команда

    cd terraform
    terraform output

вывод

    network_id = "enpc3qsud5u2021n8bo2"
    subnet_private_a_id = "e9bl55ubng6lph1h6tui"
    subnet_private_b_id = "e2l8rpjjrn63jark6usn"
    subnet_public_id = "e9bpqcop0foerkh6q0cu"

---
