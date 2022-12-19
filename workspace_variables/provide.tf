terraform {

  cloud {
    hostname     = "app.terraform.io"
    organization = "dakual"

    workspaces {
      tags = [
        "networking"
      ]
    }
  }

  required_version = ">= 1.3.6"
}