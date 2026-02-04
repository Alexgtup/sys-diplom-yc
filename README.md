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
- [X] web vm x2 + alb
- [X] zabbix + agents
- [ ] elastic + kibana + filebeat
- [ ] snapshots schedule

---

## 1 сеть и подсети

создан vpc `sys-diplom` и 3 подсети
public (ru-central1-a)
private-a (ru-central1-a)
private-b (ru-central1-b)

где смотреть: vpc - сети - sys-diplom

![vpc subnets](img/01-vpc-subnets.png)

2 nat и маршрутизация private

для private подсетей включен исходящий доступ в интернет через nat gateway
создана route table с маршрутом `0.0.0.0/0` через nat и привязана к private-a и private-b

где смотреть:
vpc - шлюзы - sys-diplom-nat
vpc - таблицы маршрутизации - sys-diplom-private-rt
vpc - подсети - sys-diplom-private-a / sys-diplom-private-b (поле таблица маршрутизации)

![nat gateway](img/02-nat-gateway.png)
![route table](img/03-route-table.png)
![private a rt](img/04-private-a-rt.png)
![private b rt](img/05-private-b-rt.png)

## 4 security groups

sg разнесены по ролям: bastion, web, zabbix, elastic, kibana, alb
наружу открыты только нужные порты, ssh к внутренним vm только через bastion

![sg list](img/06-sg-list.png)
![sg bastion](img/07-sg-bastion.png)
![sg web](img/08-sg-web.png)
![sg elastic](img/09-sg-elastic.png)
![sg kibana](img/10-sg-kibana.png)

## 5 bastion

vm `bastion` в public подсети с публичным ip, вход только ssh

![bastion vm](img/11-bastion-vm.png)

## 6 web vm x2 + alb

внутри приватного контура подняты два одинаковых web-сервера в разных зонах, наружу сайт отдаётся только через application load balancer

### 6.1 web vm (private)

web vm:

- `web-a` - `sys-diplom-private-a (ru-central1-a)`, `10.10.2.4`, `web-a.ru-central1.internal`
- `web-b` - `sys-diplom-private-b (ru-central1-b)`, `10.10.3.5`, `web-b.ru-central1.internal`

у web vm нет публичных ip, подключение по ssh только через bastion

где смотреть: compute cloud - виртуальные машины

![web vms](img/12-web-vms.png)

внутренние fqdn (используются в ansible inventory, без привязки к ip)

![web-a overview](img/12-web-a-overview.png)
![web-b overview](img/12-web-b-overview.png)

### 6.2 application load balancer (public)

alb принимает http снаружи и балансирует трафик между `web-a` и `web-b`

- public ip alb: `158.160.224.121`

где смотреть: application load balancer - балансировщики

![alb](img/13-alb.png)

### 6.3 security groups (alb -> web)

доступы сделаны так, чтобы до web нельзя было достучаться напрямую:

- `sys-diplom-sg-alb` - открыт `80` наружу + `loadbalancer_healthchecks`
- `sys-diplom-sg-web` - `80` только от `sys-diplom-sg-alb`, `22` только от `sys-diplom-sg-bastion`

итог: сайт доступен только через alb, ssh только через bastion

### 6.4 nginx + тестовая страница (ansible на bastion)

nginx и тестовая страница накатаны на обе web vm через:

- `ansible/playbooks/web.yml`

проверка, что bastion видит внутренние vm:

```bash
ansible all -m ping
```

## 7 monitoring: zabbix + agents

под мониторинг поднята отдельная vm `zabbix` в public подсети, zabbix server + web ui развернуты через docker compose (postgres + zabbix-server + zabbix-web)

web ui доступен снаружи по публичному ip zabbix vm, логин по умолчанию `Admin / zabbix`

![zabbix vm](img/15-zabbix-vm.png)
![zabbix ui](img/16-zabbix-ui-login.png)

на `web-a` и `web-b` установлен `zabbix-agent`, сервер опрашивает агентов по `10050/tcp` (в sg web вход на 10050 разрешён только от sg zabbix)

плейбук: `ansible/playbooks/zabbix-agent.yml`

в интерфейсе zabbix добавлены хосты `web-a` и `web-b` с подключением по dns `*.ru-central1.internal:10050`, после чего начинают поступать метрики и доступны latest data / graphs

![zabbix hosts](img/17-zabbix-hosts.png)
![zabbix latest](img/18-zabbix-latest.png)
