locals {
  api_backends = length(var.api_backends) > 0 ? var.api_backends : formatlist("etcd-%d.${var.node_name_suffix}", range(3))
}
module "hiera" {
  count = var.lb_count > 0 ? 1 : 0

  source = "../vshn-lbaas-hieradata"

  api_backends             = local.api_backends
  router_backends          = var.router_backends
  bootstrap_node           = var.bootstrap_node
  node_name_suffix         = var.node_name_suffix
  cluster_id               = var.cluster_id
  distribution             = var.distribution
  ingress_controller       = var.ingress_controller
  lb_names                 = random_id.lb[*].hex
  lb_cloudscale_api_secret = var.lb_cloudscale_api_secret
  hieradata_repo_user      = var.hieradata_repo_user
  api_vip                  = cidrhost(cloudscale_floating_ip.api_vip[0].network, 0)
  internal_vip             = var.internal_vip
  nat_vip                  = cidrhost(cloudscale_floating_ip.nat_vip[0].network, 0)
  router_vip               = cidrhost(cloudscale_floating_ip.router_vip[0].network, 0)
}
