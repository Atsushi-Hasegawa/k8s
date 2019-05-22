output "cluster_ca_certificate" {
  value = "${base64decode(google_container_cluster.gke.master_auth.0.cluster_ca_certificate)}"
}

output "client_key" {
  value = "${base64decode(google_container_cluster.gke.master_auth.0.client_key)}"
}

output "client_certificate" {
  value = "${base64decode(google_container_cluster.gke.master_auth.0.client_certificate)}"
}

output "id" {
  value = "${google_container_cluster.gke.id}"
}

output "gcloud_config_id" {
  value = "${null_resource.gcloud_config.id}"
}

output "endpoint" {
  value = "${google_container_cluster.gke.endpoint}"
}

output "host" {
  value = "https://${google_container_cluster.gke.endpoint}"
}

output "username" {
  value = "${google_container_cluster.gke.master_auth.0.username}"
}

output "password" {
  value = "${google_container_cluster.gke.master_auth.0.password}"
}
