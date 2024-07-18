resource "cloudscale_floating_ip" "api_vip" {
  count       = var.lb_count != 0 && !var.use_existing_vips && var.enable_api_vip ? 1 : 0
  ip_version  = 4
  region_slug = var.region
  reverse_ptr = "api.${var.node_name_suffix}"

  lifecycle {
    ignore_changes = [
      # Will be handled by Keepalived (Ursula)
      server,
    ]
  }
}

data "cloudscale_floating_ip" "api_vip" {
  count       = var.use_existing_vips ? 1 : 0
  ip_version  = 4
  reverse_ptr = "api.${var.node_name_suffix}"
}

resource "cloudscale_floating_ip" "router_vip" {
  count       = var.lb_count != 0 && !var.use_existing_vips && var.enable_router_vip ? 1 : 0
  ip_version  = 4
  region_slug = var.region
  reverse_ptr = "ingress.${var.node_name_suffix}"

  lifecycle {
    ignore_changes = [
      # Will be handled by Keepalived (Ursula)
      server,
    ]
  }
}

data "cloudscale_floating_ip" "router_vip" {
  count       = var.use_existing_vips ? 1 : 0
  ip_version  = 4
  reverse_ptr = "ingress.${var.node_name_suffix}"
}

resource "cloudscale_floating_ip" "nat_vip" {
  count       = var.lb_count != 0 && !var.use_existing_vips && var.enable_nat_vip ? 1 : 0
  ip_version  = 4
  region_slug = var.region
  reverse_ptr = "egress.${var.node_name_suffix}"

  lifecycle {
    ignore_changes = [
      # Will be handled by Keepalived (Ursula)
      server,
    ]
  }
}

data "cloudscale_floating_ip" "nat_vip" {
  count       = var.use_existing_vips ? 1 : 0
  ip_version  = 4
  reverse_ptr = "egress.${var.node_name_suffix}"
}

resource "random_id" "lb" {
  count       = var.lb_count
  prefix      = "lb-"
  byte_length = 1
}

resource "cloudscale_server_group" "lb" {
  count     = var.lb_count != 0 ? 1 : 0
  name      = "lb-group"
  type      = "anti-affinity"
  zone_slug = "${var.region}1"
}

locals {
  api_vip    = var.use_existing_vips ? data.cloudscale_floating_ip.api_vip : cloudscale_floating_ip.api_vip
  router_vip = var.use_existing_vips ? data.cloudscale_floating_ip.router_vip : cloudscale_floating_ip.router_vip
  nat_vip    = var.use_existing_vips ? data.cloudscale_floating_ip.nat_vip : cloudscale_floating_ip.nat_vip

  instance_fqdns = formatlist("%s.${var.node_name_suffix}", random_id.lb[*].hex)

  common_user_data = {
    "package_update"  = true,
    "package_upgrade" = true,
    "runcmd" = [
      "sleep '5'",
      "wget -O /tmp/puppet-source.deb https://apt.puppetlabs.com/puppet7-release-focal.deb",
      "dpkg -i /tmp/puppet-source.deb",
      "rm /tmp/puppet-source.deb",
      "apt-get update",
      "apt-get -y install puppet-agent",
      "apt-get -y purge snapd",
      "mkdir -p /etc/puppetlabs/facter/facts.d",
      "netplan apply",
      ["bash", "-c",
      "set +e -x; for ((i=0; i < 3; ++i)); do /opt/puppetlabs/bin/puppet facts && break; done; for ((i=0; i < 3; ++i)); do /opt/puppetlabs/bin/puppet agent -t --server master.puppet.vshn.net --environment AppuioLbaas && break; done"],
      "sleep 5",
      "shutdown --reboot +1 'Reboot for system setup'",
    ],
    "manage_etc_hosts" = true,
    "write_files" = [
      {
        path       = "/etc/netplan/60-ens4.yaml"
        "encoding" = "b64"
        "content" = base64encode(yamlencode({
          "network" = {
            "ethernets" = {
              "ens4" = {
                "dhcp4" = true,
              },
            },
            "version" = 2,
          }
        }))
      }
    ]
  }
}

resource "null_resource" "register_lb" {
  triggers = {
    # Refresh resource when script changes -- this is probaby not required for production
    script_sha1 = filesha1("${path.module}/files/register-server.sh")
    # Refresh resource when lb fqdn changes
    lb_id = local.instance_fqdns[count.index]
  }

  count = var.lb_count

  provisioner "local-exec" {
    command = "${path.module}/files/register-server.sh"
    environment = {
      CONTROL_VSHN_NET_TOKEN = var.control_vshn_net_token
      SERVER_FQDN            = local.instance_fqdns[count.index]
      SERVER_REGION          = "${var.region}.ch"
      # Cluster id is used as encdata stage
      CLUSTER_ID = var.cluster_id
    }
  }
}

resource "cloudscale_server" "lb" {
  count                          = var.lb_count
  name                           = local.instance_fqdns[count.index]
  zone_slug                      = "${var.region}1"
  flavor_slug                    = var.lb_flavor
  image_slug                     = "ubuntu-20.04"
  server_group_ids               = var.lb_count != 0 ? [cloudscale_server_group.lb[0].id] : []
  volume_size_gb                 = 50
  ssh_keys                       = var.ssh_keys
  skip_waiting_for_ssh_host_keys = true

  interfaces {
    type = "public"
  }
  interfaces {
    type         = "private"
    network_uuid = var.privnet_id
  }

  dynamic "interfaces" {
    for_each = var.additional_networks
    content {
      type         = "private"
      network_uuid = interfaces.value
    }
  }

  lifecycle {
    ignore_changes = [
      skip_waiting_for_ssh_host_keys,
      image_slug,
      user_data,
    ]
    create_before_destroy = true
  }

  user_data = format("#cloud-config\n%s", yamlencode(merge(
    local.common_user_data,
    {
      "fqdn"     = local.instance_fqdns[count.index],
      "hostname" = random_id.lb[count.index].hex,
    }
  )))

  depends_on = [
    null_resource.register_lb,
  ]
}
