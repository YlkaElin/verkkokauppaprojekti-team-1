
// Tässä alustavat pipelinen luontiin tarvittavat palikat - tarvitsee triggeriin vielä cloudbuild.yamlin joka ei ole tehtynä.
// toimii hashicorp/google providerin versiolla 3.5 ja 4.4 eli normilla ja uusimmalla

# ----------------------------------------
# DEPLOY A GOOGLE CLOUD SOURCE REPOSITORY
# ----------------------------------------

resource "google_sourcerepo_repository" "repo" {
  name = var.repository_name
}

#-----------------
# Cloud Run Service
#-----------------
resource "google_cloud_run_service" "default" {
  name     = var.service_name   //määritellään outputissa?
  location = var.location       // määritellään outputissa?

  template {
    spec {
      containers {
        image = local.image_name //käytettävä image
      }
    }
  }

  //tässä voi määritellä ympäristömuuttujat esim sql-kannan yhteyden ottamiseen
    #env {
    #  name  = "INSTANCE_CONNECTION_NAME"
    #  value = local.instance_connection_name
    #}
    #
    #env {
    #  name  = "POSTGRES_DATABASE"
    #  value = var.db_name
    #}
    #
    #env {
    #  name  = "POSTGRES_USERNAME"
    #  value = var.db_username
    #}
    #
    #env {
    #  name  = "POSTGRES_PASSWORD"
    #  value = var.db_password
    #}

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# ---------------------------------------------------
# Cloud Run Service Publicly Available
# ---------------------------------------------------

resource "google_cloud_run_service_iam_member" "allUsers" {
  service  = google_cloud_run_service.service.name
  location = google_cloud_run_service.service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# ------------------------------
# Cloud Build Trigger
# ------------------------------

resource "google_cloudbuild_trigger" "cloud_build_trigger" {
  description = "Cloud Source Repository Trigger ${var.repository_name} (${var.branch_name})"

  trigger_template {
    branch_name = var.branch_name
    repo_name   = var.repository_name
  }

  # These substitutions have been defined in the sample app's cloudbuild.yaml file.
  substitutions = {
    _LOCATION     = var.location
    _GCR_REGION   = var.gcr_region
    _SERVICE_NAME = var.service_name
  }

  # The filename argument instructs Cloud Build to look for a file in the root of the repository.
  # Either a filename or build template (below) must be provided.
  filename = "cloudbuild.yaml"

  depends_on = [google_sourcerepo_repository.repo]
}

# -------------------------------
# OPTIONALLY DEPLOY A DATABASE
#   huom alkuperäinen käytti mysql:ää, tämä saattaa vaatia tunkkaamista
# -------------------------------

resource "google_sql_database_instance" "master" {
  count            = var.deploy_db ? 1 : 0 //tarkastaa, että deplataanko db, deplaa yhden jos true, ei deplaa mitään jos false
  name             = var.db_instance_name
  region           = var.location
  database_version = "POSTGRES_13" //HUOM TSEK TÄMÄ

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "default" {
  count = var.deploy_db ? 1 : 0

  name     = var.db_name
  project  = var.project
  instance = google_sql_database_instance.master[0].name

  depends_on = [google_sql_database_instance.master]
}

resource "google_sql_user" "default" {
  count = var.deploy_db ? 1 : 0

  project  = var.project
  name     = var.db_username
  instance = google_sql_database_instance.master[0].name
  password = var.db_password

  depends_on = [google_sql_database.default]
}

# ---------
# LOCALS
# ---------

locals {
  image_name = var.image_name == "" ? "${var.gcr_region}.gcr.io/${var.project}/${var.service_name}" : var.image_name
  # uncomment the following line to connect to the cloud sql database instance
  #instance_connection_name = "${var.project}:${var.location}:${google_sql_database_instance.master[0].name}"
}