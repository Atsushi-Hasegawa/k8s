variable "project" {}
variable "region" {}

variable "spinnaker_account" {
  default = "spinnaker-account"
}

variable "spinnaker_roles" {
  type = "list"

  default = [
    "roles/storage.admin",
    "roles/browser",
  ]
}

variable "halyard_account" {
  default = "halyard-account"
}

variable "halyard_roles" {
  type = "list"

  default = [
    "roles/iam.serviceAccountKeyAdmin",
    "roles/container.admin",
  ]
}

variable "container" {
  type = "map"

  default = {
    name         = "deploy-server"
    node_name    = "deploy-server-node"
    node_count   = 2
    location     = "asia-northeast1"
    zone         = "asia-northeast1-a"
    machine_type = "n1-standard-2"
    preemptible  = true
  }
}

variable "kubernetes" {
  type = "map"

  default = {
    account_name   = "spinnaker-account"
    name           = "spinnaker-admin"
    namespace      = "spinnaker"
    subject_kind   = "ServiceAccount"
    role_api_group = "rbac.authorization.k8s.io"
    role_kind      = "ClusterRole"
    role_name      = "cluster-admin"
  }
}

variable "gcs_location" {
  default = "asia-northeast1"
}

variable "spinnaker_version" {
  default = "1.8.5"
}

variable "deploy_account" {
  default = "my-k8s-v2-account"
}

variable "docker_registry" {
  default = "gcp-gcr"
}

provider "google" {
  credentials = "${file("config/account.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
}
