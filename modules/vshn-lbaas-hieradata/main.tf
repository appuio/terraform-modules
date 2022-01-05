locals {
  instance_fqdns = formatlist("%s.${var.node_name_suffix}", var.lb_names)

  lb_count = length(var.lb_names)

  api_credentials = var.cloud_provider == "cloudscale" ? var.lb_api_credentials.cloudscale : var.lb_api_credentials.exoscale

  public_interface   = var.cloud_provider == "cloudscale" ? "ens3" : "eth0"
  private_interfaces = var.cloud_provider == "cloudscale" ? ["ens4"] : ["eth1"]
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
      "cloud_provider"     = var.cloud_provider
      "cluster_id"         = var.cluster_id
      "distribution"       = var.distribution
      "ingress_controller" = var.ingress_controller
      "api_credentials"    = local.api_credentials
      "api_vip"            = var.api_vip
      "internal_vip"       = var.internal_vip
      "nat_vip"            = var.nat_vip
      "router_vip"         = var.router_vip
      "public_interface"   = local.public_interface
      "private_interfaces" = local.private_interfaces
      "nodes"              = local.instance_fqdns
      "backends" = {
        "api"    = var.api_backends[*]
        "router" = var.router_backends[*],
      }
      "enable_proxy_protocol" = var.enable_proxy_protocol
      "bootstrap_node"        = var.bootstrap_node
      "team"                  = var.team
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
