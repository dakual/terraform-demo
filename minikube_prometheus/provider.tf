terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }

  required_version = ">= 1.2.5"
}

provider "kubernetes" {
  config_context_cluster = "minikube"
  config_path            = pathexpand(var.kube_config)
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kube_config)
  }
}

provider "kubectl" {
  config_context_cluster = "minikube"
  config_path            = pathexpand(var.kube_config)
}