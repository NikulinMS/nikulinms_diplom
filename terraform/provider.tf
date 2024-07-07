# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    } 
  }
}

provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id = "${var.yc_id}"
  folder_id = "${var.yf_id}"
}