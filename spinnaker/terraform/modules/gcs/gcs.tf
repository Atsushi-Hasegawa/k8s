
resource "google_storage_bucket" "spinnaker_config" {
  name          = "deploy-${var.project}-spinnaker-config"
  location      = "${var.gcs_location}"
  storage_class = "NEARLINE"
  force_destroy = "true"
}

data "template_file" "deploy_spinnaker" {
  template = <<EOF
set -ex \
&& GCS_KEY_FILE=~/.hal/.$${bucket}.key \
&& echo '$${gcs_json_key}' | base64 --decode > $GCS_KEY_FILE \
&& hal -q config provider kubernetes enable \
&& hal -q config provider kubernetes account delete my-k8s-v2-account || true \
&& hal -q config provider kubernetes account add my-k8s-v2-account --provider-version v2 --context $(kubectl config current-context) \
&& hal -q config features edit --artifacts true \
&& hal -q config deploy edit --type distributed --account-name my-k8s-v2-account \
&& hal -q config storage gcs edit --project $${project} --bucket-location $${gcs_location} --json-path $GCS_KEY_FILE --bucket $${bucket} \
&& hal -q config storage edit --type gcs \
&& hal -q config version edit --version $${spinnaker_version} \
&& hal -q deploy apply
EOF

  vars {
    project           = "${var.project}"
    gcs_location      = "${var.gcs_location}"
    bucket            = "${google_storage_bucket.spinnaker_config.name}"
    gcs_json_key      = "${var.service_account_key}"
    spinnaker_version = "${var.spinnaker_version}"
  }
}

# Configure kubectl to use spinnaker service account
resource "null_resource" "deploy_spinnaker" {
  provisioner "local-exec" {
    command = "${data.template_file.deploy_spinnaker.rendered}"
  }
}
