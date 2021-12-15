# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The project ID where all resources will be launched."
  type        = string
}

variable "location" {
  description = "The location (region or zone) to deploy the Cloud Run services. Note: Be sure to pick a region that supports Cloud Run."
  type        = string
}

variable "gcr_region" {
  description = "Name of the GCP region where the GCR registry is located. e.g: 'us' or 'eu'."
  type        = string
}

variable "credentials file" {
  description = "Juukeli, kredentiaalit"
  type = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Muodostuu default-arvo jos terraform.tfvarsissa ei määritellä näille muuttujille arvoja
# ---------------------------------------------------------------------------------------------------------------------

variable "service_name" {
  description = "The name of the Cloud Run service to deploy."
  type        = string
  default     = "docker-service"
}

variable "repository_name" {
  description = "Name of the Google Cloud Source Repository to create."
  type        = string
  default     = "docker-app"
}

variable "image_name" {
  description = "The name of the image to deploy. Defaults to a publically available image."
  type        = string
  default     = "gcr.io/cloudrun/hello" //eli hello world lähtee liipasimseta jos ei ole mitää imagea saatavilla
}

variable "branch_name" {
  description = "Example branch name used to trigger builds."
  type        = string
  default     = "main" //vaihdettu tähän main
}

variable "digest" {
  description = "The docker image digest or tag to deploy."
  type        = string
  default     = "latest"
}

variable "deploy_db" {
  description = "Whether to deploy a Cloud SQL database or not."
  type        = bool
  default     = false
}

variable "db_instance_name" {
  description = "The name of the Cloud SQL database instance."
  type        = string
  default     = "main-instance"
}

variable "db_name" {
  description = "The name of the Cloud SQL database."
  type        = string
  default     = "exampledb"
}

variable "db_username" {
  description = "The name of the Cloud SQL database user."
  type        = string
  default     = "testuser"
}

variable "db_password" {
  description = "The password of the Cloud SQL database user."
  type        = string
  default     = "testpassword" 
}