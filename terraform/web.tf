resource "yandex_compute_instance" "web_a" {
  name     = "web-a"
  hostname = "web-a"
  zone     = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu2204.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_a.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web.id]
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file("${path.module}/${var.ssh_public_key_path}")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "web_b" {
  name     = "web-b"
  hostname = "web-b"
  zone     = "ru-central1-b"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu2204.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_b.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web.id]
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file("${path.module}/${var.ssh_public_key_path}")}"
  }

  scheduling_policy {
    preemptible = true
  }
}
