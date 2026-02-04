resource "yandex_compute_snapshot_schedule" "sys_diplom_daily" {
  name = "sys-diplom-daily"

  schedule_policy {
    # ежедневно в 03:00 UTC
    expression = "0 3 * * *"
  }

  retention_period = "168h"

  snapshot_spec {
    description = "sys-diplom daily snapshots (7d retention)"
  }

  disk_ids = [
    yandex_compute_instance.bastion.boot_disk[0].disk_id,
    yandex_compute_instance.web_a.boot_disk[0].disk_id,
    yandex_compute_instance.web_b.boot_disk[0].disk_id,
    yandex_compute_instance.zabbix.boot_disk[0].disk_id,
    yandex_compute_instance.elastic.boot_disk[0].disk_id,
    yandex_compute_instance.kibana.boot_disk[0].disk_id,
  ]
}
