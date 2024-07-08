// Create SA
resource "yandex_iam_service_account" "sa-diplom" {
  name = "sa-diplom"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "diplom-editor" {
#  cloud_id = var.yc_id
   folder_id = var.yf_id
  role = "editor"
  member = "serviceAccount:${yandex_iam_service_account.sa-diplom.id}"
  depends_on = [ yandex_iam_service_account.sa-diplom ]
}

//Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa-diplom.id
  description = "static access key"
}

//Use keys to create bucket
resource "yandex_storage_bucket" "nikulin-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "nikulin-bucket"
  acl = "private"
  force_destroy = true
  depends_on = [ yandex_resourcemanager_folder_iam_member.diplom-editor ]
}

//Create "local_file" for "backendConf"
resource "local_file" "backendConf" {
  content = <<EOT
bucket = "${yandex_storage_bucket.nikulin-bucket.bucket}"
region = "ru-central1"
key = "terraform/terraform.tfstate"
access_key = "${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
secret_key = "${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"
skip_region_validation = true
skip_credentials_validation = true
skip_requesting_account_id  = true 
skip_s3_checksum            = true 
EOT
  filename = "../secret.backend.tfvars"
}
