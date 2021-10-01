locals {
  instance_fqdns = formatlist("%s.${var.node_name_suffix}", var.lb_names)

  lb_count = length(var.lb_names)
}

resource "gitfile_checkout" "appuio_hieradata" {
  repo = "https://${var.hieradata_repo_user}@git.vshn.net/appuio/appuio_hieradata.git"
  path = "${path.root}/appuio_hieradata"

  lifecycle {
    ignore_changes = [
      branch
    ]
  }
}

resource "local_file" "lb_hieradata" {
  content = templatefile(
    "${path.module}/templates/hieradata.yaml.tmpl",
    {
      "cluster_id"         = var.cluster_id
      "distribution"       = var.distribution
      "ingress_controller" = var.ingress_controller
      "api_secret"         = var.lb_cloudscale_api_secret
      "api_vip"            = var.api_vip
      "internal_vip"       = var.internal_vip
      "nat_vip"            = var.nat_vip
      "router_vip"         = var.router_vip
      "nodes"              = local.instance_fqdns
      "backends" = {
        "api"    = var.api_backends[*]
        "router" = var.router_backends[*],
      }
      "bootstrap_node" = var.bootstrap_node
  })

  filename             = "${path.cwd}/appuio_hieradata/lbaas/${var.cluster_id}.yaml"
  file_permission      = "0644"
  directory_permission = "0755"

  depends_on = [
    gitfile_checkout.appuio_hieradata
  ]

  provisioner "local-exec" {
    command = "${path.module}/files/commit-hieradata.sh ${var.cluster_id} ${path.cwd}/.mr_url.txt"
  }
}

data "local_file" "hieradata_mr_url" {
  count = local.lb_count > 0 ? 1 : 0

  filename = "${path.cwd}/.mr_url.txt"

  depends_on = [
    local_file.lb_hieradata
  ]
}
