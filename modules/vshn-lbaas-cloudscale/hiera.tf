locals {
  api_backends = length(var.api_backends) > 0 ? var.api_backends : formatlist("etcd-%d.${var.node_name_suffix}", range(3))
}
module "hiera" {
  count = var.lb_count > 0 ? 1 : 0

  source = "../vshn-lbaas-hieradata"

  cloud_provider = "cloudscale"

  api_backends          = var.enable_haproxy ? local.api_backends : []
  router_backends       = var.enable_haproxy ? var.router_backends : []
  bootstrap_node        = var.enable_haproxy ? var.bootstrap_node : ""
  node_name_suffix      = var.node_name_suffix
  cluster_id            = var.cluster_id
  distribution          = var.distribution
  ingress_controller    = var.ingress_controller
  lb_names              = random_id.lb[*].hex
  hieradata_repo_user   = var.hieradata_repo_user
  api_vip               = var.enable_haproxy ? cidrhost(cloudscale_floating_ip.api_vip[0].network, 0) : ""
  internal_vip          = var.enable_haproxy ? var.internal_vip : ""
  nat_vip               = cidrhost(cloudscale_floating_ip.nat_vip[0].network, 0)
  router_vip            = var.enable_haproxy ? cidrhost(cloudscale_floating_ip.router_vip[0].network, 0) : ""
  team                  = var.team
  enable_proxy_protocol = var.enable_proxy_protocol
  enable_haproxy        = var.enable_haproxy

  lb_api_credentials = {
    cloudscale = {
      token = var.lb_cloudscale_api_secret
    }
    exoscale = null
  }
}
