locals {
  cluster             = "test"
  environment         = "dev"
  region              = "eu-central-1"
  internalCertARN     = "arn:aws:acm:eu-central-1:632296647497:certificate/3bb4db5c-486d-4af6-8b93-7ecde36c70a3"
}

data "aws_eks_cluster" "main" {
  name = local.cluster
}

resource "kubernetes_namespace" "nginx" {
  metadata {
    labels = {
      name = "ingress-nginx"
    }
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_nginx" {
  name              = "ingress-nginx"
  repository        = "https://kubernetes.github.io/ingress-nginx"
  chart             = "ingress-nginx"
  namespace         = kubernetes_namespace.nginx.metadata.0.name
  version           = "4.4.0"
  create_namespace  = false
  timeout           = 300
  wait_for_jobs     = true 
  wait              = true

  values = [
    templatefile("${path.module}/configs/nginx_ingress.yml", {
      internalIngress = true
      internalCertARN = local.internalCertARN
    })
  ]

  depends_on = [
    kubernetes_namespace.nginx
  ]
}

