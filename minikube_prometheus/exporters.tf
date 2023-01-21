data "kubectl_path_documents" "exporters" {
  pattern = "${path.module}/exporters/*.yml"
}

resource "kubectl_manifest" "exporters" {
  for_each  = { for k in toset(data.kubectl_path_documents.exporters.documents) : k => k if true }
  yaml_body = each.value

  depends_on = [
    helm_release.prometheus,
    helm_release.grafana
  ]
}
