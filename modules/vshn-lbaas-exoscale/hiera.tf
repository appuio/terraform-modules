locals {
  api_backends = length(var.api_backends) > 0 ? (
    var.api_backends
  ) : formatlist("etcd-%d.${var.exoscale_domain_name}", range(3))
  internal_vip = var.cluster_network.enabled ? (
    cidrhost(local.network_cidr, var.cluster_network.internal_vip_host)
  ) : ""
  nat_vip = var.cluster_network.enabled ? exoscale_ipaddress.nat[0].ip_address : ""
}
module "hiera" {
  count = var.lb_count > 0 ? 1 : 0

  source = "../vshn-lbaas-hieradata"

  cloud_provider = "exoscale"

  api_backends          = local.api_backends
  router_backends       = var.router_backends
  bootstrap_node        = var.bootstrap_node
  node_name_suffix      = data.exoscale_domain.cluster.name
  cluster_id            = var.cluster_id
  distribution          = var.distribution
  ingress_controller    = var.ingress_controller
  lb_names              = random_id.lb[*].hex
  hieradata_repo_user   = var.hieradata_repo_user
  api_vip               = exoscale_ipaddress.api.ip_address
  internal_vip          = local.internal_vip
  nat_vip               = ""
  router_vip            = exoscale_ipaddress.ingress.ip_address
  team                  = var.team
  enable_proxy_protocol = var.enable_proxy_protocol

  lb_api_credentials = {
    cloudscale = null
    exoscale = {
      key    = var.lb_exoscale_api_key
      secret = var.lb_exoscale_api_secret
    }
  }
}
