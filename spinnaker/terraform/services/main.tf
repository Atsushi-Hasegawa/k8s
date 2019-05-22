module "iam" {
  source            = "../modules/iam"
  spinnaker_account = "${var.spinnaker_account}"
  spinnaker_roles   = "${var.spinnaker_roles}"
  halyard_account   = "${var.halyard_account}"
  halyard_roles     = "${var.halyard_roles}"
  project           = "${var.project}"
}

module "container" {
  source          = "../modules/container"
  container       = "${var.container}"
  project         = "${var.project}"
  service_account = "${module.iam.service_account}"
}

provider "kubernetes" {
  load_config_file       = false
  version                = "~> 1.6"
  host                   = "${module.container.host}"
  username               = "${module.container.username}"
  password               = "${module.container.password}"
  client_certificate     = "${module.container.client_certificate}"
  client_key             = "${module.container.client_key}"
  cluster_ca_certificate = "${module.container.cluster_ca_certificate}"
}

module "spinnaker" {
  source       = "../modules/spinnaker"
  project      = "${var.project}"
  cluster_name = "${module.container.id}"
  kubernetes   = "${var.kubernetes}"

  depends_on = [
    "${module.container.gcloud_config_id}",
  ]
}

module "gcs" {
  source              = "../modules/gcs"
  project             = "${var.project}"
  gcs_location        = "${var.gcs_location}"
  service_account_key = "${module.iam.service_account_key}"
  spinnaker_version = "${var.spinnaker_version}"
}
