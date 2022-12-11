locals {
  region            = "eu-central-1"
  namespace         = "default"
  domain            = "kruta.link"
  ingress_svc_name  = "ingress-nginx-controller"

  ingress_load_balancer_tags = {
    "kubernetes.io/cluster/${data.aws_eks_cluster.main.id}" = "owned"
    "kubernetes.io/service-name"                            = "${local.namespace}/${local.ingress_svc_name}"
  }
}

data "terraform_remote_state" "eks" {
  backend = "remote"

  config = {
    organization = "dakual"
    workspaces = {
      name = "aws_eks_cluster"
    }
  }
}

data "aws_eks_cluster" "main" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}
