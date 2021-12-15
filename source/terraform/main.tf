# Terraformin alustus
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.3.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.zone
}

provider "google-beta" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.zone
}

# Google Cloud Source Repository
resource "google_sourcerepo_repository" "repo" {
  name = var.repository_name
}

# API rakennus
resource "google_api_gateway_api" "hannibal-api" {
  provider     = google-beta
  api_id       = "hannibal-gateway"
  display_name = "hannibal-api"
}

# API config
resource "google_api_gateway_api_config" "hannibal-api" {
  provider      = google-beta
  api           = google_api_gateway_api.hannibal-api.api_id
  api_config_id = "hannibal-api-config"

  openapi_documents {
    document {
      path     = "spec.yaml"
      contents = filebase64("../api-gateway/api-config.yaml")
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway
resource "google_api_gateway_gateway" "hannibal-api" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.hannibal-api.id
  gateway_id = "hannibal-gateway"
}


# Ämpäri jossa koodit funktioille????
resource "google_storage_bucket" "bucket" {
  provider = google
  name     = "juukeli-bucket"
}

# Laitetaan koodit ämpäriin????
resource "google_storage_bucket_object" "functions" {
  provider = google
  name     = "functions"
  bucket   = google_storage_bucket.bucket.name
  source   = "./functions.zip"
}

# luo funktio zipistä joka on bucketissa?????
resource "google_cloudfunctions_function" "function" {
  provider    = google
  name        = "function-test"
  description = "My function"
  runtime     = "python38"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  #source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "helloGET"
}

# IAM entry for all users to invoke the function
# Pitää olla et toimii julkisesti nää funktiot????????
resource "google_cloudfunctions_function_iam_member" "invoker" {
  provider       = google
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}