locals {
    workspace_path = "${path.module}/workspaces/${terraform.workspace}.yaml" 
    defaults       = file("${path.module}/workspaces/default.yaml")

    workspace = fileexists(local.workspace_path) ? file(local.workspace_path) : yamlencode({})
    var       = merge(
        yamldecode(local.defaults),
        yamldecode(local.workspace)
    )
}
