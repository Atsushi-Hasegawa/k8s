# create spinnaker namespace
resource "kubernetes_namespace" "spinnaker_namespace" {
  metadata {
   annotations {
     depends-id = "${join(",", var.depends_on)}"
   }
   name = "${lookup(var.kubernetes, "namespace")}"
  }
}

resource "kubernetes_service_account" "spinnaker_account" {
  depends_on = [
     "kubernetes_namespace.spinnaker_namespace",
  ]
  metadata {
    name = "${lookup(var.kubernetes, "account_name")}"
    namespace = "${lookup(var.kubernetes, "namespace")}"
  }
}

resource "kubernetes_cluster_role_binding" "client_role_binding" {
  depends_on = [
     "kubernetes_service_account.spinnaker_account",
  ]
  metadata {
    name = "${lookup(var.kubernetes, "name")}"
  }
  role_ref {
    name = "${lookup(var.kubernetes, "role_name")}"
    kind = "${lookup(var.kubernetes, "role_kind")}"
    api_group = "${lookup(var.kubernetes, "role_api_group")}"
  }
  subject {
    kind = "User"
    name = "client"
  }
  subject {
    name = "${lookup(var.kubernetes, "account_name")}"
    namespace = "${lookup(var.kubernetes, "namespace")}"
    kind = "${lookup(var.kubernetes, "subject_kind")}"
  }
}

data "template_file" "kubectl_config" {
  depends_on = [
    "kubernetes_service_account.spinnaker_account",
  ]
  template = <<EOF
set -ex \
&& CONTEXT=$(kubectl config current-context) \
&& SECRET_NAME=$(kubectl get serviceaccount $${account} --namespace $${namespace} -o jsonpath='{.secrets[0].name}') \
&& TOKEN=$(kubectl get secret --namespace $${namespace} $SECRET_NAME -o yaml  -o jsonpath='{.data.token}' | base64 --decode) \
&& kubectl config set-credentials $CONTEXT-token-user --token $TOKEN \
&& kubectl config set-context $CONTEXT --user $CONTEXT-token-user
EOF

  vars {
    namespace = "${kubernetes_service_account.spinnaker_account.metadata.0.namespace}"
    account   = "${kubernetes_service_account.spinnaker_account.metadata.0.name}"
  }
}

# Configure kubectl to use spinnaker service account
resource "null_resource" "kubectl_config" {
  depends_on = [
    "kubernetes_cluster_role_binding.client_role_binding",
  ]

  provisioner "local-exec" {
    command = "${data.template_file.kubectl_config.rendered}"
  }
}
