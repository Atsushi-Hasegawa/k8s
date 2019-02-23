resource "google_service_account" "iam-service-account" {
  count = "${length(var.serviceaccount)}"
  account_id = "${lookup(var.serviceaccount[count.index], "account")}"
  display_name = "${lookup(var.serviceaccount[count.index], "account")}"
}

resource "google_project_iam_binding" "iam-policy" {
  project = "${var.project}"
  role = "${lookup(var.serviceaccount[count.index], "role")}"
  members = [
    "serviceAccount:${google_service_account.iam-service-account.email}"
  ]
}

resource "google_service_account_key" "service_key" {
  service_account_id = "${google_service_account.iam-service-account.name}"
  public_key_type = "TYPE_X509_PEM_FILE"
}
