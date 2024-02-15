locals {
  api_backends = length(var.api_backends) > 0 ? (
    var.api_backends
  ) : formatlist("etcd-%d.${var.exoscale_domain_name}", range(3))
  internal_vip = var.cluster_network.enabled ? (
    cidrhost(local.network_cidr, var.cluster_network.internal_vip_host)
  ) : ""
  nat_vip = var.cluster_network.enabled ? exoscale_elastic_ip.nat[0].ip_address : ""
}

resource "exoscale_iam_role" "floaty" {
  name        = "${var.cluster_id}_floaty"
  description = "Exoscale IAMv3 role for Floaty for ${var.cluster_id}"
  // TBD if we want to set `editable=false` -- note that this also prevents
  // updates via Terraform
  editable = true

  policy = {
    default_service_strategy = "deny"

    services = {
      compute-legacy = {
        type = "rules"
        rules = [
          {
            action     = "allow"
            expression = "operation in ['compute-add-ip-to-nic', 'compute-list-nics', 'compute-list-resource-details', 'compute-list-virtual-machines', 'compute-query-async-job-result', 'compute-remove-ip-from-nic']"
          }
        ]
      }
      compute = {
        type = "rules"
        rules = [
          {
            action     = "allow"
            expression = "operation in ['get-instance', 'list-instances', 'list-elastic-ips']"
          },
          {
            action     = "allow"
            expression = "operation in ['attach-instance-to-elastic-ip', 'detach-instance-from-elastic-ip'] && resources.elastic_ip.ip in ['${exoscale_elastic_ip.api.ip_address}', '${exoscale_elastic_ip.ingress.ip_address}']"
          }
        ]
      }
    }
  }
}

resource "exoscale_iam_api_key" "floaty" {
  name    = "${var.cluster_id}_floaty"
  role_id = exoscale_iam_role.floaty.id
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
  api_vip               = exoscale_elastic_ip.api.ip_address
  internal_vip          = local.internal_vip
  nat_vip               = ""
  router_vip            = exoscale_elastic_ip.ingress.ip_address
  team                  = var.team
  enable_proxy_protocol = var.enable_proxy_protocol

  lb_api_credentials = {
    cloudscale = null
    exoscale = {
      key    = exoscale_iam_api_key.floaty.key
      secret = nonsensitive(exoscale_iam_api_key.floaty.secret)
    }
  }
}
