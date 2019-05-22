resource "google_container_cluster" "gke" {
  name                     = "${lookup(var.container, "name")}"
  zone                     = "${lookup(var.container, "zone")}"
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "spinnaker" {
  name       = "${lookup(var.container, "node_name")}"
  zone       = "${lookup(var.container, "zone")}"
  cluster    = "${google_container_cluster.gke.name}"
  node_count = "${lookup(var.container, "node_count")}"

  node_config {
    preemptible  = "${lookup(var.container, "preemptible")}"
    machine_type = "${lookup(var.container, "machine_type")}"

    metadata {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

data "template_file" "gcloud_config" {
  template = <<EOF
    set -xe \
    && gcloud config configurations create terraform || true \
    && gcloud config configurations activate terraform \
    && gcloud config set container/use_application_default_credentials true \
    && gcloud auth activate-service-account --key-file=$${file_path} --project=$${project} \
    && gcloud container clusters --zone=$${zone} --project=$${project} get-credentials $${cluster_name} \
    && kubectl version
EOF

  vars {
    zone         = "${lookup(var.container, "zone")}"
    project = "${var.project}"
    file_path    = "${path.module}/../../services/config/account.json"
    cluster_name = "${google_container_cluster.gke.id}"
  }
}

resource "null_resource" "gcloud_config" {
  provisioner "local-exec" {
    command = "${data.template_file.gcloud_config.rendered}"
  }
}
