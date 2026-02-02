resource "yandex_vpc_gateway" "nat" {
  name = "${var.vpc_name}-nat"

  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private" {
  name       = "${var.vpc_name}-private-rt"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}
