# sys-diplom yc

дипломная работа netology: отказоустойчивая инфраструктура для сайта в yandex cloud
инструменты: terraform + ansible

## 0 требования

- токены и ключи yandex cloud в git не выкладываются
- ansible inventory только fqdn *.ru-central1.internal (без ip)
- web vm без публичных ip, ssh только через bastion
- доступ к сайту через application load balancer
- monitoring: zabbix + agents, дашборды use + пороги
- logs: elasticsearch + kibana + filebeat (nginx access/error)
- backups: snapshots daily, хранение 7 дней

## 0.1 текущий прогресс

- [X] сеть vpc + подсети
- [X] nat gateway + route table для private подсетей
- [ ] security groups
- [ ] bastion vm
- [ ] web vm x2 + alb
- [ ] zabbix + agents
- [ ] elastic + kibana + filebeat
- [ ] snapshots schedule

## 1 сеть и подсети

создан vpc `sys-diplom` и 3 подсети

- public (ru-central1-a)
- private-a (ru-central1-a)
- private-b (ru-central1-b)

скрин: vpc -> сети -> sys-diplom
![vpc subnets](img/01-vpc-subnets.png)

## 2 nat и маршрутизация для private

для private подсетей настроен исходящий доступ в интернет через nat gateway
создана route table с маршрутом `0.0.0.0/0` через nat и привязана к private-a/private-b

скрины:

- vpc -> шлюзы -> sys-diplom-nat
- vpc -> таблицы маршрутизации -> sys-diplom-private-rt
- vpc -> подсети -> sys-diplom-private-a / private-b (поле таблица маршрутизации)

![nat gateway](img/02-nat-gateway.png)
![route table](img/03-route-table.png)
![private a rt](img/04-private-a-rt.png)
![private b rt](img/05-private-b-rt.png)

## 3 terraform outputs

команда:

```bash
cd terraform
terraform output
```

```
network_id = "enpc3qsud5u2021n8bo2"
subnet_private_a_id = "e9bl55ubng6lph1h6tui"
subnet_private_b_id = "e2l8rpjjrn63jark6usn"
subnet_public_id = "e9bpqcop0foerkh6q0cu"

```
