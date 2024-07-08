# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)  
3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

### Решение

1. Создал новый workspace и сервисный аккаунт в нем
![img_1.png](img%2Fimg_1.png)

2. Для подготовки ```backend``` для Terraform выбрал рекомендуемый вариант S3 bucket:
- для начала подготовил [bucket.tf](terraform%2Fbucket%2Fbucket.tf) для создания сервисного аккаунта по управлению bucket и созданию хранилища для backend, нужные данные для доступа к bucket выносятся в файл ```secret.backend.tfvars``` для инициализации основного terraform:

<details>
<summary>terraform apply</summary>

```bash
nikulinn@nikulin:~/other/nikulinms_diplom/terraform/bucket$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.backendConf will be created
  + resource "local_file" "backendConf" {
      + content              = (sensitive value)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "../secret.backend.tfvars"
      + id                   = (known after apply)
    }

  # yandex_iam_service_account.sa-diplom will be created
  + resource "yandex_iam_service_account" "sa-diplom" {
      + created_at = (known after apply)
      + folder_id  = (known after apply)
      + id         = (known after apply)
      + name       = "sa-diplom"
    }

  # yandex_iam_service_account_static_access_key.sa-static-key will be created
  + resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
      + access_key           = (known after apply)
      + created_at           = (known after apply)
      + description          = "static access key"
      + encrypted_secret_key = (known after apply)
      + id                   = (known after apply)
      + key_fingerprint      = (known after apply)
      + secret_key           = (sensitive value)
      + service_account_id   = (known after apply)
    }

  # yandex_resourcemanager_folder_iam_member.diplom-editor will be created
  + resource "yandex_resourcemanager_folder_iam_member" "diplom-editor" {
      + folder_id = "b1gjh7prfs9fus38l32u"
      + id        = (known after apply)
      + member    = (known after apply)
      + role      = "editor"
    }

  # yandex_storage_bucket.nikulin-bucket will be created
  + resource "yandex_storage_bucket" "nikulin-bucket" {
      + access_key            = (known after apply)
      + acl                   = "private"
      + bucket                = "nikulin-bucket"
      + bucket_domain_name    = (known after apply)
      + default_storage_class = (known after apply)
      + folder_id             = (known after apply)
      + force_destroy         = true
      + id                    = (known after apply)
      + secret_key            = (sensitive value)
      + website_domain        = (known after apply)
      + website_endpoint      = (known after apply)

      + anonymous_access_flags (known after apply)

      + versioning (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_iam_service_account.sa-diplom: Creating...
yandex_iam_service_account.sa-diplom: Creation complete after 3s [id=ajedkbp515tjfjmii5m2]
yandex_resourcemanager_folder_iam_member.diplom-editor: Creating...
yandex_iam_service_account_static_access_key.sa-static-key: Creating...
yandex_iam_service_account_static_access_key.sa-static-key: Creation complete after 2s [id=ajecpekvh3gicmcg48sd]
yandex_resourcemanager_folder_iam_member.diplom-editor: Creation complete after 5s [id=b1gjh7prfs9fus38l32u/editor/serviceAccount:ajedkbp515tjfjmii5m2]
yandex_storage_bucket.nikulin-bucket: Creating...
yandex_storage_bucket.nikulin-bucket: Creation complete after 3s [id=nikulin-bucket]
local_file.backendConf: Creating...
local_file.backendConf: Creation complete after 0s [id=7e4163c8ada24f9b0c14a52d3e8738f9cde64821]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```
</details>

![img_2.png](img%2Fimg_2.png)
![img_3.png](img%2Fimg_3.png)

- инициализируем основной terraform, используя данные из ```secret.backend.tfvars``` для доступа к bucket:
[provider.tf](terraform%2Fprovider.tf)
<details>
<summary>terraform init -backend-config=secret.backend.tfvars</summary>

```bash
nikulinn@nikulin:~/other/nikulinms_diplom/terraform$ terraform init -backend-config=secret.backend.tfvars
Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
Initializing provider plugins...
- Finding latest version of yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.123.0...
- Installed yandex-cloud/yandex v0.123.0 (unauthenticated)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

╷
│ Warning: Incomplete lock file information for providers
│ 
│ Due to your customized provider installation methods, Terraform was forced to calculate lock file checksums locally for the following providers:
│   - yandex-cloud/yandex
│ 
│ The current .terraform.lock.hcl file only includes checksums for linux_amd64, so Terraform running on another platform will fail to install these providers.
│ 
│ To calculate additional checksums for another platform, run:
│   terraform providers lock -platform=linux_amd64
│ (where linux_amd64 is the platform to generate)
╵
Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary
```

</details>

backend:
![img_4.png](img%2Fimg_4.png)

- создал VPC с подсетями в разных зонах доступности:
![img_5.png](img%2Fimg_5.png)

- выполнение команды ```terraform destroy``` и ```terraform apply``` без дополнительных ручных действий:
<details>
<summary>terraform apply --auto-approve</summary>

```bash
nikulinn@nikulin:~/other/nikulinms_diplom/terraform$ terraform apply --auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.k8s-cluster[0] will be created
  + resource "yandex_compute_instance" "k8s-cluster" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "node-0"
      + id                        = (known after apply)
      + labels                    = {
          + "index" = "0"
        }
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0Qq5LD6aWZn4QWPRtDE5ckaHpJYGWhi0+dCi3qerMJ3TeWBS6EZLBhq3EPPDd5wqkJ32Sgi3bYISFvM4ShXr0nh8ekf0z1Al2r1XF+ZKW88X9dkx61KAjRNngy9dl6b/iqnIzhq2jnIfoLiEBVI9qtwrDk04o7HJLnMyOFPTPfZwEkWclqB5LzJDn7zybR9aaI1dNvNt7LwnzUOvv1pOE/lkkB0mMwcbGRP9M/9fIk6nSf+z5qtATHWfXNa6vbwV4inTA8VOC0A1+hevECI3xMjoHw/mq34JsJ/QHJh/87vbhJWKo8hEWJqVoQNoTkmVn00pzwkOrs7ejawsmJkcHbgt5GHRBTGi3B+hEKvhZflC2cdpqapoGkU660Fuwl1JgVFqd6c3OwGfFRpylYBdCr9EI0fkt/CI9XshHc1l5OkG6NuXQ3kPfWGFmEhSSE1fj2nPcDUsbbGKhAP+LEgSm33p2RyQrEkjgRNUP+KzS/E98GD6nt4MUKtisQ9JlJ8M= nikulinn@nikulin
            EOT
        }
      + name                      = "node-0"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v2"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8l04iucc4vsh00rkb1"
              + name        = (known after apply)
              + size        = 30
              + snapshot_id = (known after apply)
              + type        = "network-ssd"
            }
        }

      + metadata_options (known after apply)

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy (known after apply)

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.k8s-cluster[1] will be created
  + resource "yandex_compute_instance" "k8s-cluster" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "node-1"
      + id                        = (known after apply)
      + labels                    = {
          + "index" = "1"
        }
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0Qq5LD6aWZn4QWPRtDE5ckaHpJYGWhi0+dCi3qerMJ3TeWBS6EZLBhq3EPPDd5wqkJ32Sgi3bYISFvM4ShXr0nh8ekf0z1Al2r1XF+ZKW88X9dkx61KAjRNngy9dl6b/iqnIzhq2jnIfoLiEBVI9qtwrDk04o7HJLnMyOFPTPfZwEkWclqB5LzJDn7zybR9aaI1dNvNt7LwnzUOvv1pOE/lkkB0mMwcbGRP9M/9fIk6nSf+z5qtATHWfXNa6vbwV4inTA8VOC0A1+hevECI3xMjoHw/mq34JsJ/QHJh/87vbhJWKo8hEWJqVoQNoTkmVn00pzwkOrs7ejawsmJkcHbgt5GHRBTGi3B+hEKvhZflC2cdpqapoGkU660Fuwl1JgVFqd6c3OwGfFRpylYBdCr9EI0fkt/CI9XshHc1l5OkG6NuXQ3kPfWGFmEhSSE1fj2nPcDUsbbGKhAP+LEgSm33p2RyQrEkjgRNUP+KzS/E98GD6nt4MUKtisQ9JlJ8M= nikulinn@nikulin
            EOT
        }
      + name                      = "node-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v2"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-b"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8l04iucc4vsh00rkb1"
              + name        = (known after apply)
              + size        = 30
              + snapshot_id = (known after apply)
              + type        = "network-ssd"
            }
        }

      + metadata_options (known after apply)

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy (known after apply)

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.k8s-cluster[2] will be created
  + resource "yandex_compute_instance" "k8s-cluster" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "node-2"
      + id                        = (known after apply)
      + labels                    = {
          + "index" = "2"
        }
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0Qq5LD6aWZn4QWPRtDE5ckaHpJYGWhi0+dCi3qerMJ3TeWBS6EZLBhq3EPPDd5wqkJ32Sgi3bYISFvM4ShXr0nh8ekf0z1Al2r1XF+ZKW88X9dkx61KAjRNngy9dl6b/iqnIzhq2jnIfoLiEBVI9qtwrDk04o7HJLnMyOFPTPfZwEkWclqB5LzJDn7zybR9aaI1dNvNt7LwnzUOvv1pOE/lkkB0mMwcbGRP9M/9fIk6nSf+z5qtATHWfXNa6vbwV4inTA8VOC0A1+hevECI3xMjoHw/mq34JsJ/QHJh/87vbhJWKo8hEWJqVoQNoTkmVn00pzwkOrs7ejawsmJkcHbgt5GHRBTGi3B+hEKvhZflC2cdpqapoGkU660Fuwl1JgVFqd6c3OwGfFRpylYBdCr9EI0fkt/CI9XshHc1l5OkG6NuXQ3kPfWGFmEhSSE1fj2nPcDUsbbGKhAP+LEgSm33p2RyQrEkjgRNUP+KzS/E98GD6nt4MUKtisQ9JlJ8M= nikulinn@nikulin
            EOT
        }
      + name                      = "node-2"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v2"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-d"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8l04iucc4vsh00rkb1"
              + name        = (known after apply)
              + size        = 30
              + snapshot_id = (known after apply)
              + type        = "network-ssd"
            }
        }

      + metadata_options (known after apply)

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy (known after apply)

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_vpc_network.app-net will be created
  + resource "yandex_vpc_network" "app-net" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "app-net"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.app-subnet-zones[0] will be created
  + resource "yandex_vpc_subnet" "app-subnet-zones" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet-ru-central1-a"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.10.1.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # yandex_vpc_subnet.app-subnet-zones[1] will be created
  + resource "yandex_vpc_subnet" "app-subnet-zones" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet-ru-central1-b"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.10.2.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # yandex_vpc_subnet.app-subnet-zones[2] will be created
  + resource "yandex_vpc_subnet" "app-subnet-zones" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet-ru-central1-d"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.10.3.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-d"
    }

Plan: 7 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_nodes = {
      + node-0 = (known after apply)
      + node-1 = (known after apply)
      + node-2 = (known after apply)
    }
  + internal_ip_address_nodes = {
      + node-0 = (known after apply)
      + node-1 = (known after apply)
      + node-2 = (known after apply)
    }
yandex_vpc_network.app-net: Creating...
yandex_vpc_network.app-net: Creation complete after 3s [id=enptippa997k8n9d7t7g]
yandex_vpc_subnet.app-subnet-zones[2]: Creating...
yandex_vpc_subnet.app-subnet-zones[1]: Creating...
yandex_vpc_subnet.app-subnet-zones[0]: Creating...
yandex_vpc_subnet.app-subnet-zones[2]: Creation complete after 1s [id=fl85hi0f0fstrv0241c7]
yandex_vpc_subnet.app-subnet-zones[0]: Creation complete after 1s [id=e9bpequs2l0hcfchkhf6]
yandex_vpc_subnet.app-subnet-zones[1]: Creation complete after 1s [id=e2lulcijv0a2vaaj0lsn]
yandex_compute_instance.k8s-cluster[2]: Creating...
yandex_compute_instance.k8s-cluster[0]: Creating...
yandex_compute_instance.k8s-cluster[1]: Creating...
yandex_compute_instance.k8s-cluster[1]: Still creating... [10s elapsed]
yandex_compute_instance.k8s-cluster[0]: Still creating... [10s elapsed]
yandex_compute_instance.k8s-cluster[2]: Still creating... [10s elapsed]
yandex_compute_instance.k8s-cluster[2]: Still creating... [20s elapsed]
yandex_compute_instance.k8s-cluster[1]: Still creating... [20s elapsed]
yandex_compute_instance.k8s-cluster[0]: Still creating... [20s elapsed]
yandex_compute_instance.k8s-cluster[1]: Still creating... [30s elapsed]
yandex_compute_instance.k8s-cluster[2]: Still creating... [30s elapsed]
yandex_compute_instance.k8s-cluster[0]: Still creating... [30s elapsed]
yandex_compute_instance.k8s-cluster[0]: Creation complete after 35s [id=fhmt8aukpcj8i70koq4p]
yandex_compute_instance.k8s-cluster[1]: Creation complete after 39s [id=epd096399tok18bdjevb]
yandex_compute_instance.k8s-cluster[2]: Still creating... [40s elapsed]
yandex_compute_instance.k8s-cluster[2]: Creation complete after 45s [id=fv4obd5mepe60m0r0atk]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_nodes = {
  "node-0" = "158.160.44.112"
  "node-1" = "158.160.23.1"
  "node-2" = "158.160.159.210"
}
internal_ip_address_nodes = {
  "node-0" = "10.10.1.34"
  "node-1" = "10.10.2.9"
  "node-2" = "10.10.3.14"
}
```

</details>

- При длительной неактивности Yandex отключает виртуальные машины, при повторном включении происходит смена публичных адресов, что разрушит кластер k8s, который мы будем разворачивать на следующем этапе. Поэтому, на текущем этапе, имеет смысл дополнительно произвести небольшие манипуляции для стабилизации кластера, а именно - зарезервировать полученные адреса к Yandex Cloud:
![img_6.png](img%2Fimg_6.png)
![img_7.png](img%2Fimg_7.png)

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.


### Решение

Выбран вариант создания кластера k8s, используя Kubespray:

- Скачаем репозиторий, используя команду ```git clone https://github.com/kubernetes-sigs/kubespray```
- Переходим в директорию ```kubespray``` и запускаем установку зависимости ```pip3.11 install -r requirements.txt```
- Создаем директорию ```inventory/mycluster```, копированием образца: ```cp -rfp inventory/sample inventory/mycluster```
- Используя адреса хостов, полученные на прошлом этапе, создадим файл ```hosts.yaml```
```bash
nikulinn@nikulin:~/other/nikulinms_diplom/kubespray$ declare -a IPS=(158.160.44.112 158.160.23.1 158.160.159.210)
nikulinn@nikulin:~/other/nikulinms_diplom/kubespray$ CONFIG_FILE=inventory/mycluster/hosts.yaml python3.11 contrib/inventory_builder/inventory.py ${IPS[@]}
DEBUG: Adding group all
DEBUG: Adding group kube_control_plane
DEBUG: Adding group kube_node
DEBUG: Adding group etcd
DEBUG: Adding group k8s_cluster
DEBUG: Adding group calico_rr
DEBUG: adding host node1 to group all
DEBUG: adding host node2 to group all
DEBUG: adding host node3 to group all
DEBUG: adding host node1 to group etcd
DEBUG: adding host node2 to group etcd
DEBUG: adding host node3 to group etcd
DEBUG: adding host node1 to group kube_control_plane
DEBUG: adding host node2 to group kube_control_plane
DEBUG: adding host node1 to group kube_node
DEBUG: adding host node2 to group kube_node
DEBUG: adding host node3 to group kube_node
```
- Правим полученный файл под нужды текущей задачи kubespray/inventory/mycluster/hosts.yaml
```bash
all:
  hosts:
    node1:
      ansible_host: 158.160.44.112
      ip: 10.10.1.34
    node2:
      ansible_host: 158.160.23.1
      ip: 10.10.2.9
    node3:
      ansible_host: 158.160.159.210
      ip: 10.10.3.14
  children:
    kube_control_plane:
      hosts:
        node1:
    kube_node:
      hosts:
        node2:
        node3:
    etcd:
      hosts:
        node1:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
```
- Для доступа к кластеру извне нужно добавить параметр supplementary_addresses_in_ssl_keys: [158.160.44.112] в файл inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml, что является ip мастер ноды.
- И далее запускаем установку Kubernetes командой:
```bash
ansible-playbook -i inventory/mycluster/hosts.yaml -u ubuntu --become --become-user=root cluster.yml
```
```bash
PLAY RECAP *************************************************************************************************************************************************************************************************
node1                      : ok=632  changed=139  unreachable=0    failed=0    skipped=1113 rescued=0    ignored=6   
node2                      : ok=416  changed=87   unreachable=0    failed=0    skipped=673  rescued=0    ignored=1   
node3                      : ok=416  changed=87   unreachable=0    failed=0    skipped=669  rescued=0    ignored=1   

Tuesday 09 July 2024  00:33:07 +0500 (0:00:00.204)       0:12:42.606 ********** 
=============================================================================== 
download : Download_file | Download item ----------------------------------------------------------------------------------------------------------------------------------------------------------- 78.41s
kubernetes/control-plane : Kubeadm | Initialize first master --------------------------------------------------------------------------------------------------------------------------------------- 53.65s
download : Download_file | Download item ----------------------------------------------------------------------------------------------------------------------------------------------------------- 40.75s
download : Download_container | Download image if required ----------------------------------------------------------------------------------------------------------------------------------------- 27.33s
download : Download_container | Download image if required ----------------------------------------------------------------------------------------------------------------------------------------- 20.93s
download : Download_container | Download image if required ----------------------------------------------------------------------------------------------------------------------------------------- 17.69s
kubernetes/kubeadm : Join to cluster --------------------------------------------------------------------------------------------------------------------------------------------------------------- 16.32s
kubernetes/preinstall : Update package management cache (APT) -------------------------------------------------------------------------------------------------------------------------------------- 14.50s
kubernetes/preinstall : Install packages requirements ---------------------------------------------------------------------------------------------------------------------------------------------- 11.77s
kubernetes-apps/ansible : Kubernetes Apps | Lay Down CoreDNS templates ----------------------------------------------------------------------------------------------------------------------------- 11.57s
download : Download_container | Download image if required ----------------------------------------------------------------------------------------------------------------------------------------- 10.66s
network_plugin/calico : Wait for calico kubeconfig to be created ------------------------------------------------------------------------------------------------------------------------------------ 9.35s
kubernetes/node : Install | Copy kubelet binary from download dir ----------------------------------------------------------------------------------------------------------------------------------- 8.36s
etcd : Reload etcd ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 8.24s
download : Download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------ 7.56s
download : Download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------ 7.07s
network_plugin/calico : Calico | Create calico manifests -------------------------------------------------------------------------------------------------------------------------------------------- 6.32s
kubernetes-apps/ansible : Kubernetes Apps | Start Resources ----------------------------------------------------------------------------------------------------------------------------------------- 5.81s
container-engine/containerd : Download_file | Download item ----------------------------------------------------------------------------------------------------------------------------------------- 5.35s
etcd : Configure | Check if etcd cluster is healthy ------------------------------------------------------------------------------------------------------------------------------------------------- 5.34s
```
- Копируем ~/.kube/config с мастер ноды командой:
```bash
nikulinn@nikulin:~/other/nikulinms_diplom/kubespray$ mkdir -p ~/.kube && ssh ubuntu@158.160.44.112 "sudo cat /root/.kube/config" >> ~/.kube/config
The authenticity of host '158.160.44.112 (158.160.44.112)' can't be established.
ECDSA key fingerprint is SHA256:VxkWCGH1BDzv80B5QKOnwPqi6ZWFgWTWI/Kl+7QhE9o.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '158.160.44.112' (ECDSA) to the list of known hosts.
```
- Заменяем ip на внешний ip мастер ноды: https://158.160.44.112:6443
- Кластер создан, доступно подключение через интернет:

```bash
nikulinn@nikulin:~/other/nikulinms_diplom/kubespray$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-c7cc688f8-mgkjb   1/1     Running   0          6m17s
kube-system   calico-node-fz8mg                         1/1     Running   0          6m45s
kube-system   calico-node-lmjw9                         1/1     Running   0          6m45s
kube-system   calico-node-njx9x                         1/1     Running   0          6m45s
kube-system   coredns-776bb9db5d-w92l4                  1/1     Running   0          5m54s
kube-system   coredns-776bb9db5d-zvx94                  1/1     Running   0          5m58s
kube-system   dns-autoscaler-6ffb84bd6-cpflp            1/1     Running   0          5m55s
kube-system   kube-apiserver-node1                      1/1     Running   1          7m56s
kube-system   kube-controller-manager-node1             1/1     Running   2          8m
kube-system   kube-proxy-7b59w                          1/1     Running   0          7m17s
kube-system   kube-proxy-jqv9v                          1/1     Running   0          7m17s
kube-system   kube-proxy-nfzp8                          1/1     Running   0          7m17s
kube-system   kube-scheduler-node1                      1/1     Running   1          8m
kube-system   nginx-proxy-node2                         1/1     Running   0          7m10s
kube-system   nginx-proxy-node3                         1/1     Running   0          7m19s
kube-system   nodelocaldns-5kk5x                        1/1     Running   0          5m54s
kube-system   nodelocaldns-6gxzq                        1/1     Running   0          5m54s
kube-system   nodelocaldns-kks5d                        1/1     Running   0          5m54s

nikulinn@nikulin:~/other/nikulinms_diplom/kubespray$ kubectl get nodes
NAME    STATUS   ROLES           AGE     VERSION
node1   Ready    control-plane   8m48s   v1.30.2
node2   Ready    <none>          7m48s   v1.30.2
node3   Ready    <none>          7m48s   v1.30.2
```

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

### Решение

Использовать будем рекомендуемый вариант.

Создаём каталог app и подкаталоги conf и content:
```bash
mkdir -p ~/test_app/{conf,content} && cd ~/test_app/
```

- В каталоге test_app создаем [Dockerfile](test_app%2FDockerfile):
```yaml
FROM nginx:latest

# Configuration
COPY conf /etc/nginx
# Content
COPY content /usr/share/nginx/html

#Health Check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost/ || exit 1

EXPOSE 80
```
- Также создаём файл ~/test_app/conf/nginx.conf с конфигурацией [nginx.conf](test_app%2Fconf%2Fnginx.conf):
```yaml
user nginx;
worker_processes 1;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections 1024;
    multi_accept on;
}

http {
    server {
        listen   80;

        location / {
            gzip off;
            root /usr/share/nginx/html/;
            index index.html;
        }
    }
    keepalive_timeout  60;
}
```
- Cоздаём статическую страницу нашего приложения [index.html](test_app%2Fcontent%2Findex.html):
```html
<!DOCTYPE html>
<html lang="ru">

<head>
    <meta charset="utf-8" name="viewport" content="width=device-width, initial-scale=1" />
    <title>Diploma of Nikulin Michail</title>
</head>

<body>
    <h2 style="margin-top: 150px; text-align: center;">Diploma of Nikulin Michail</h2>
</body>

</html>
```
- Создаем образ:

<details>
<summary>docker build -t nikulinm/nginx-static-app .</summary>

```bash
nikulinn@nikulin:~/other/nikulinms_diplom/test_app$ docker build -t nikulinm/nginx-static-app .
[+] Building 10.2s (9/9) FINISHED                                                                                                                                                            docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                                   0.1s
 => => transferring dockerfile: 258B                                                                                                                                                                   0.0s
 => [internal] load metadata for docker.io/library/nginx:latest                                                                                                                                        2.4s
 => [auth] library/nginx:pull token for registry-1.docker.io                                                                                                                                           0.0s
 => [internal] load .dockerignore                                                                                                                                                                      0.0s
 => => transferring context: 2B                                                                                                                                                                        0.0s
 => [1/3] FROM docker.io/library/nginx:latest@sha256:67682bda769fae1ccf5183192b8daf37b64cae99c6c3302650f6f8bf5f0f95df                                                                                  7.0s
 => => resolve docker.io/library/nginx:latest@sha256:67682bda769fae1ccf5183192b8daf37b64cae99c6c3302650f6f8bf5f0f95df                                                                                  0.0s
 => => sha256:c6b156574604a095a5847d3b34cf36d484bb49862365e996b391d0ba0f345034 41.83MB / 41.83MB                                                                                                       1.6s
 => => sha256:ea5d7144c337402f813ea7c05c11dab58b7841f4c41fb5f5058abefbc2451ec5 628B / 628B                                                                                                             0.7s
 => => sha256:db5e49f40979ce521f05f0bc9f513d0abacce47904e229f3a95c2e6d9b47f244 2.29kB / 2.29kB                                                                                                         0.0s
 => => sha256:fffffc90d343cbcb01a5032edac86db5998c536cd0a366514121a45c6723765c 7.30kB / 7.30kB                                                                                                         0.0s
 => => sha256:f11c1adaa26e078479ccdd45312ea3b88476441b91be0ec898a7e07bfd05badc 29.13MB / 29.13MB                                                                                                       0.8s
 => => sha256:67682bda769fae1ccf5183192b8daf37b64cae99c6c3302650f6f8bf5f0f95df 10.27kB / 10.27kB                                                                                                       0.0s
 => => sha256:537a6cfe3404285310129c72dfc3f352e7c5db1a5f296e514d739322bab5a998 393B / 393B                                                                                                             1.0s
 => => sha256:1bbcb9df2c93e03db739f7e49ce73eda0325b8087ef8e88386d303d883c357ab 955B / 955B                                                                                                             1.0s
 => => extracting sha256:f11c1adaa26e078479ccdd45312ea3b88476441b91be0ec898a7e07bfd05badc                                                                                                              2.3s
 => => sha256:767bff2cc03ef46478039907c5bca487eb27d5f43a38571985e4ed4dc0403d5a 1.21kB / 1.21kB                                                                                                         1.2s
 => => sha256:adc73cb74f2591613c7c88f7f6a313c3373bbfa3bda0983677bb233668b4033a 1.40kB / 1.40kB                                                                                                         1.3s
 => => extracting sha256:c6b156574604a095a5847d3b34cf36d484bb49862365e996b391d0ba0f345034                                                                                                              3.1s
 => => extracting sha256:ea5d7144c337402f813ea7c05c11dab58b7841f4c41fb5f5058abefbc2451ec5                                                                                                              0.0s
 => => extracting sha256:1bbcb9df2c93e03db739f7e49ce73eda0325b8087ef8e88386d303d883c357ab                                                                                                              0.0s
 => => extracting sha256:537a6cfe3404285310129c72dfc3f352e7c5db1a5f296e514d739322bab5a998                                                                                                              0.0s
 => => extracting sha256:767bff2cc03ef46478039907c5bca487eb27d5f43a38571985e4ed4dc0403d5a                                                                                                              0.0s
 => => extracting sha256:adc73cb74f2591613c7c88f7f6a313c3373bbfa3bda0983677bb233668b4033a                                                                                                              0.0s
 => [internal] load build context                                                                                                                                                                      0.0s
 => => transferring context: 781B                                                                                                                                                                      0.0s
 => [2/3] COPY conf /etc/nginx                                                                                                                                                                         0.4s
 => [3/3] COPY content /usr/share/nginx/html                                                                                                                                                           0.0s
 => exporting to image                                                                                                                                                                                 0.1s
 => => exporting layers                                                                                                                                                                                0.0s
 => => writing image sha256:a2ddea10433596ec91d6489bf65958bb2d4e7ed623f08fd2219cd6baac81c4ad                                                                                                           0.0s
 => => naming to docker.io/nikulinm/nginx-static-app 
```

</details>

- Для проверки соберем и запустим контейнер, проверим доступ к приложению:

```bash
nikulinn@nikulin:~/other/nikulinms_diplom/test_app$ docker run -d --name app -p80:80 nikulinm/nginx-static-app:latest 
946c2ff434d3417e5f8834810c4d4ec6218f7ffa3d56fd24c8734228cb1c4de8
nikulinn@nikulin:~/other/nikulinms_diplom/test_app$ docker image ls
REPOSITORY                  TAG       IMAGE ID       CREATED       SIZE
nikulinm/nginx-static-app   latest    a2ddea104335   3 hours ago   188MB
nikulinn@nikulin:~/other/nikulinms_diplom/test_app$ docker ps
CONTAINER ID   IMAGE                              COMMAND                  CREATED          STATUS                             PORTS                               NAMES
946c2ff434d3   nikulinm/nginx-static-app:latest   "/docker-entrypoint.…"   17 seconds ago   Up 15 seconds (health: starting)   0.0.0.0:80->80/tcp, :::80->80/tcp   app
```
![img_8.png](img%2Fimg_8.png)

- Образ успешно собран и приложение отвечает, отправим его в DockerHub:

![img_9.png](img%2Fimg_9.png)
![img_10.png](img%2Fimg_10.png)

```bash
docker pull nikulinms/nginx-static-app
```

- Для размещения приложения выбран GitHub:

https://github.com/NikulinMS/test_app.git

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

2. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)