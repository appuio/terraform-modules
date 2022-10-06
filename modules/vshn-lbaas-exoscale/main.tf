data "exoscale_domain" "cluster" {
  name = var.exoscale_domain_name
}

data "exoscale_private_network" "clusternet" {
  count = var.cluster_network.enabled ? 1 : 0
  name  = var.cluster_network.name
  zone  = var.region
}

resource "exoscale_private_network" "lbnet" {
  count = var.cluster_network.enabled ? 0 : 1

  zone        = var.region
  name        = "${var.cluster_id}_lb_vrrp"
  description = "${var.cluster_id} private network for LB VRRP traffic"
  start_ip    = cidrhost(local.lbnet_cidr, 101)
  end_ip      = cidrhost(local.lbnet_cidr, 253)
  netmask     = cidrnetmask(local.lbnet_cidr)
}

resource "exoscale_elastic_ip" "api" {
  zone        = var.region
  description = "${var.cluster_id} elastic IP for API"
}
resource "exoscale_domain_record" "api" {
  domain      = data.exoscale_domain.cluster.id
  name        = "api"
  ttl         = 60
  record_type = "A"
  content     = exoscale_elastic_ip.api.ip_address
}

resource "exoscale_elastic_ip" "ingress" {
  zone        = var.region
  description = "${var.cluster_id} elastic IP for ingress controller"
}
resource "exoscale_domain_record" "ingress" {
  domain      = data.exoscale_domain.cluster.id
  name        = "ingress"
  ttl         = 60
  record_type = "A"
  content     = exoscale_elastic_ip.ingress.ip_address
}
resource "exoscale_domain_record" "wildcard" {
  domain      = data.exoscale_domain.cluster.id
  name        = "*.apps"
  ttl         = 60
  record_type = "CNAME"
  content     = exoscale_domain_record.ingress.hostname
}

resource "exoscale_elastic_ip" "nat" {
  count       = var.cluster_network.enabled ? 1 : 0
  zone        = var.region
  description = "${var.cluster_id} elastic IP for NAT gateway"
}
resource "exoscale_domain_record" "egress" {
  count       = var.cluster_network.enabled ? 1 : 0
  domain      = data.exoscale_domain.cluster.id
  name        = "egress"
  ttl         = 60
  record_type = "A"
  content     = exoscale_elastic_ip.nat[0].ip_address
}

resource "random_id" "lb" {
  count       = var.lb_count
  prefix      = "lb-"
  byte_length = 1
}

data "cidr_network" "lbnet" {
  count = var.cluster_network.enabled ? 1 : 0
  ip    = data.exoscale_private_network.clusternet[0].start_ip
  mask  = data.exoscale_private_network.clusternet[0].netmask
}

locals {
  network_id = var.cluster_network.enabled ? data.exoscale_private_network.clusternet[0].id : exoscale_private_network.lbnet[0].id
  # If we create a privnet only for the LB VRRP traffic, we hardcode the CIDR
  # to 172.18.200.0/24.
  lbnet_cidr   = "172.18.200.0/24"
  network_cidr = var.cluster_network.enabled ? data.cidr_network.lbnet[0].prefix : local.lbnet_cidr

  instance_fqdns = formatlist("%s.${var.exoscale_domain_name}", random_id.lb[*].hex)

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
      "mv /run/tmp/ec2_userdata_override.yaml /etc/puppetlabs/facter/facts.d/",
      "netplan apply",
      ["bash", "-c",
      "set +e -x; for ((i=0; i < 3; ++i)); do /opt/puppetlabs/bin/puppet facts && break; done; for ((i=0; i < 3; ++i)); do /opt/puppetlabs/bin/puppet agent -t --server master.puppet.vshn.net --environment AppuioLbaas && break; done"],
      "sleep 5",
      "shutdown --reboot +1 'Reboot for system setup'",
    ],
  }
  common_write_files = [
    {
      path       = "/etc/netplan/60-eth1.yaml"
      "encoding" = "b64"
      "content" = base64encode(yamlencode({
        "network" = {
          "ethernets" = {
            "eth1" = {
              "dhcp4" = true,
            },
          },
          "version" = 2,
        }
      }))
    }
  ]
}

resource "exoscale_anti_affinity_group" "lb" {
  name        = "${var.cluster_id}_lb"
  description = "${var.cluster_id} lb nodes"
}

data "exoscale_compute_template" "ubuntu2004" {
  zone = var.region
  name = "Linux Ubuntu 20.04 LTS 64-bit"
}

resource "null_resource" "register_lb" {
  triggers = {
    # Refresh resource when the script changes -- this is probaby not required for production
    # Uncomment this trigger if you want to test changes to `files/register-server.sh`
    # script_sha1 = filesha1("${path.module}/files/register-server.sh")
    # Refresh resource when lb fqdn changes
    lb_id = local.instance_fqdns[count.index]
  }

  count = var.lb_count

  provisioner "local-exec" {
    command = "${path.module}/files/register-server.sh"
    environment = {
      CONTROL_VSHN_NET_TOKEN = var.control_vshn_net_token
      SERVER_FQDN            = local.instance_fqdns[count.index]
      # This assumes that the first part of var.region is the encdata region
      # (country code for Exoscale).
      SERVER_REGION = split("-", var.region)[0]
      # The encdata service doesn't allow dashes, so we replace them with
      # underscores.
      # This assumes that any zone configurations already exist in Puppet
      # hieradata.
      SERVER_ZONE = replace(var.region, "-", "_")
      # Cluster id is used as encdata stage
      CLUSTER_ID = var.cluster_id
    }
  }
}

data "exoscale_security_group" "cluster" {
  count = length(var.cluster_security_group_names)
  name  = var.cluster_security_group_names[count.index]
}

resource "exoscale_compute_instance" "lb" {
  count       = var.lb_count
  name        = local.instance_fqdns[count.index]
  ssh_key     = var.ssh_key_name
  zone        = var.region
  template_id = data.exoscale_compute_template.ubuntu2004.id
  type        = var.lb_type
  disk_size   = 20

  security_group_ids = concat(
    data.exoscale_security_group.cluster[*].id,
    [exoscale_security_group.load_balancers.id]
  )
  anti_affinity_group_ids = concat(
    [exoscale_anti_affinity_group.lb.id],
    var.additional_affinity_group_ids
  )

  # Always configure privnet managed by the module
  # (either clusternet or lb_vrrp)
  network_interface {
    network_id = local.network_id
    ip_address = cidrhost(local.network_cidr, 21 + count.index)
  }

  # Configure additional interfaces for each provided privnet
  dynamic "network_interface" {
    for_each = toset(var.additional_networks)

    content {
      network_id = network_interface.value
    }
  }

  user_data = format("#cloud-config\n%s", yamlencode(merge(
    local.common_user_data,
    {
      "fqdn"             = local.instance_fqdns[count.index],
      "hostname"         = random_id.lb[count.index].hex,
      "manage_etc_hosts" = true,
    },
    // Override ec2_userdata fact with a clean copy of the userdata, as
    // Exoscale presents userdata gzipped which confuses facter completely.
    // TODO: check how we do this using server-up.
    {
      "write_files" = concat(local.common_write_files, [
        {
          path       = "/run/tmp/ec2_userdata_override.yaml"
          "encoding" = "b64"
          "content" = base64encode(yamlencode({
            "ec2_userdata" = format("#cloud-config\n%s", yamlencode(merge(
              local.common_user_data,
              {
                "fqdn"             = local.instance_fqdns[count.index],
                "hostname"         = random_id.lb[count.index].hex,
                "manage_etc_hosts" = true,
                "write_files"      = local.common_write_files,
              }
            )))
          }))
        }
      ])
    }
  )))

  lifecycle {
    ignore_changes = [
      template_id,
      user_data,
      elastic_ip_ids,
    ]
  }

  depends_on = [
    null_resource.register_lb,
    module.hiera
  ]
}

resource "exoscale_domain_record" "lb" {
  count       = var.lb_count
  domain      = data.exoscale_domain.cluster.id
  name        = random_id.lb[count.index].hex
  ttl         = 600
  record_type = "A"
  content     = exoscale_compute_instance.lb[count.index].public_ip_address
}
