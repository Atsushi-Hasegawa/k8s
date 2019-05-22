resource "google_service_account" "spinnaker_account" {
  account_id   = "${var.spinnaker_account}"
  display_name = "${var.spinnaker_account}"
}

resource "google_service_account_key" "spinnaker_account_key" {
  depends_on         = ["google_service_account.spinnaker_account"]
  service_account_id = "${google_service_account.spinnaker_account.name}"
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_project_iam_member" "spinnaker_iam_member" {
  depends_on = ["google_service_account.spinnaker_account"]
  count      = "${length(var.spinnaker_roles)}"
  role       = "${element(var.spinnaker_roles, count.index)}"
  member     = "serviceAccount:${google_service_account.spinnaker_account.email}"
}

resource "google_service_account" "halyard_account" {
  account_id   = "${var.halyard_account}"
  display_name = "${var.halyard_account}"
}

resource "google_service_account_key" "halyard_account_key" {
  depends_on         = ["google_service_account.halyard_account"]
  service_account_id = "${google_service_account.halyard_account.name}"
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_project_iam_member" "halyard_iam_member" {
  depends_on = ["google_service_account.halyard_account"]
  count      = "${length(var.halyard_roles)}"
  role       = "${element(var.halyard_roles, count.index)}"
  member     = "serviceAccount:${google_service_account.halyard_account.email}"
}

output "service_account" {
  value = "${
    map(
      "spinnaker", "${google_service_account.spinnaker_account.email}",
      "halyard", "${google_service_account.halyard_account.email}"
    )
  }"
}

output "service_account_key" {
  value = "${google_service_account_key.spinnaker_account_key.private_key}"
}
