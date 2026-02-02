resource "yandex_vpc_network" "main" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "public" {
  name           = "${var.vpc_name}-public"
  zone           = var.public_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_cidr]
}

resource "yandex_vpc_subnet" "private_a" {
  name           = "${var.vpc_name}-private-a"
  zone           = var.private_zone_a
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_cidr_a]
  route_table_id = yandex_vpc_route_table.private.id
}

resource "yandex_vpc_subnet" "private_b" {
  name           = "${var.vpc_name}-private-b"
  zone           = var.private_zone_b
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_cidr_b]
  route_table_id = yandex_vpc_route_table.private.id
}
