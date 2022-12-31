data "aws_eks_cluster" "main" {
  name = local.var.cluster
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = local.var.namespace
  }
}