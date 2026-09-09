resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kibana.id]
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }
}
