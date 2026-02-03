resource "yandex_vpc_security_group" "bastion" {
  name       = "sys-diplom-sg-bastion"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    description    = "ssh from internet (лучше потом сузить до своего ip)"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "all egress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "alb" {
  name       = "sys-diplom-sg-alb"
  network_id = yandex_vpc_network.main.id

  ingress {
    description       = "healthchecks for alb"
    protocol          = "TCP"
    port              = 30080
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    description    = "http from internet"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "all egress"
    protocol       = "ANY"
    from_port      = -1
    to_port        = -1
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "yandex_vpc_security_group" "zabbix" {
  name       = "sys-diplom-sg-zabbix"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    description    = "zabbix ui http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "zabbix ui https (на будущее)"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol          = "TCP"
    description       = "ssh only from bastion"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "zabbix server for active agents (если понадобится)"
    v4_cidr_blocks = ["10.10.0.0/16"]
    port           = 10051
  }

  egress {
    protocol       = "ANY"
    description    = "all egress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "web" {
  name       = "sys-diplom-sg-web"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol          = "TCP"
    description       = "http from alb"
    security_group_id = yandex_vpc_security_group.alb.id
    port              = 80
  }

  ingress {
    protocol          = "TCP"
    description       = "ssh only from bastion"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }

  ingress {
    protocol          = "TCP"
    description       = "zabbix agent (server polls agent)"
    security_group_id = yandex_vpc_security_group.zabbix.id
    port              = 10050
  }

  egress {
    protocol       = "ANY"
    description    = "all egress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "elastic" {
  name       = "sys-diplom-sg-elastic"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol          = "TCP"
    description       = "elasticsearch from web(filebeat)"
    security_group_id = yandex_vpc_security_group.web.id
    port              = 9200
  }

  ingress {
    protocol          = "TCP"
    description       = "elasticsearch from kibana"
    security_group_id = yandex_vpc_security_group.kibana.id
    port              = 9200
  }

  ingress {
    protocol          = "TCP"
    description       = "ssh only from bastion"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }

  ingress {
    protocol          = "TCP"
    description       = "zabbix agent"
    security_group_id = yandex_vpc_security_group.zabbix.id
    port              = 10050
  }

  egress {
    protocol       = "ANY"
    description    = "all egress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "kibana" {
  name       = "sys-diplom-sg-kibana"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    description    = "kibana ui"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol          = "TCP"
    description       = "ssh only from bastion"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }

  egress {
    protocol       = "ANY"
    description    = "all egress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
