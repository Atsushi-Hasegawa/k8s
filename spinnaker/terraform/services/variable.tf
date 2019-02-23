variable "project" {}
variable "region" {}

variable "serviceaccount" {
  type = "list"

  default = [
    {
      account = "spinnaker-sa"
      role    = "roles/storage.admin"
    }
  ]
}

provider "google" {
  credentials = "${file("config/account.json")}"
  project = "${var.project}"
  region = "${var.region}"
}
