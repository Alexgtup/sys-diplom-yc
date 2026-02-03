resource "yandex_alb_target_group" "web_tg" {
  name = "sys-diplom-web-tg"

  target {
    subnet_id  = yandex_vpc_subnet.private_a.id
    ip_address = yandex_compute_instance.web_a.network_interface[0].ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.private_b.id
    ip_address = yandex_compute_instance.web_b.network_interface[0].ip_address
  }
}

resource "yandex_alb_backend_group" "web_bg" {
  name = "sys-diplom-web-bg"

  http_backend {
    name             = "web-http"
    port             = 80
    target_group_ids = [yandex_alb_target_group.web_tg.id]
    weight           = 1

    healthcheck {
      timeout  = "2s"
      interval = "2s"

      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "router" {
  name = "sys-diplom-router"
}

resource "yandex_alb_virtual_host" "vh" {
  name           = "sys-diplom-vh"
  http_router_id = yandex_alb_http_router.router.id

  route {
    name = "root"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web_bg.id
        timeout          = "3s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "alb" {
  name       = "sys-diplom-alb"
  network_id = yandex_vpc_network.main.id

  security_group_ids = [yandex_vpc_security_group.alb.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public.id
    }
  }

  listener {
    name = "http"

    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.router.id
      }
    }
  }
}
