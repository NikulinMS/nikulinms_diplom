# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = "../key.json"
  cloud_id = "${var.yc_id}"
  folder_id = "${var.yf_id}"
  zone = var.a-zone
}