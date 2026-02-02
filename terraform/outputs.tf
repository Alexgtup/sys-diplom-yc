output "network_id" {
  value = yandex_vpc_network.main.id
}

output "subnet_public_id" {
  value = yandex_vpc_subnet.public.id
}

output "subnet_private_a_id" {
  value = yandex_vpc_subnet.private_a.id
}

output "subnet_private_b_id" {
  value = yandex_vpc_subnet.private_b.id
}
