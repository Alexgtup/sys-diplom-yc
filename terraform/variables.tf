variable "cloud_id" {
  type        = string
  description = "Yandex Cloud cloud id"
}

variable "folder_id" {
  type        = string
  description = "Yandex Cloud folder id"
}

variable "sa_key_file" {
  type        = string
  description = "Path to service account key.json (keep it outside repo)"
}

variable "default_zone" {
  type        = string
  description = "Default zone for provider operations"
  default     = "ru-central1-a"
}

variable "public_zone" {
  type    = string
  default = "ru-central1-a"
}

variable "private_zone_a" {
  type    = string
  default = "ru-central1-a"
}

variable "private_zone_b" {
  type    = string
  default = "ru-central1-b"
}

variable "vpc_name" {
  type    = string
  default = "sys-diplom"
}

variable "public_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "private_cidr_a" {
  type    = string
  default = "10.10.2.0/24"
}

variable "private_cidr_b" {
  type    = string
  default = "10.10.3.0/24"
}
