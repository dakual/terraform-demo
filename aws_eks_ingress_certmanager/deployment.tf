data "kubectl_path_documents" "k8s_deplop" {
  pattern = "${path.module}/k8s-deployments/*.yml"
}

resource "kubectl_manifest" "k8s_deplop" {
  for_each  = toset(data.kubectl_path_documents.k8s_deplop.documents)
  yaml_body = each.value

  depends_on = [
    helm_release.ingress_nginx,
    helm_release.cert_manager
  ]
}