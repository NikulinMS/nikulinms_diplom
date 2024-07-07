resource "yandex_compute_instance" "k8s-cluster" {
  count = 3
  platform_id = "standard-v2"
  name = "node-${count.index}"
  zone = "${var.subnet-zones[count.index]}"
  hostname = "node-${count.index}"
  allow_stopping_for_update = true
  labels = {
    index = "${count.index}"
  }

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "${var.OS}"
      type = "network-ssd"
      size = "30"
    }
  }
  
  network_interface {
    subnet_id = "${yandex_vpc_subnet.app-subnet-zones[count.index].id}"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}