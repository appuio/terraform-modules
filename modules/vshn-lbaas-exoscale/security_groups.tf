locals {
  # security group rules to create for TCP and UDP over IPv4 and IPv6
  open_ports = {
    "Kubernetes API"           = "6443",
    "Ingress controller HTTP"  = "80",
    "Ingress controller HTTPS" = "443",
  }
}

resource "exoscale_security_group" "load_balancers" {
  name        = "${var.cluster_id}_load_balancers"
  description = "${var.cluster_id} load balancer VMs"
}

resource "exoscale_security_group_rule" "load_balancers_tcp4" {
  for_each = local.open_ports

  security_group_id = exoscale_security_group.load_balancers.id

  type        = "INGRESS"
  description = "${each.key} TCPv4"
  protocol    = "TCP"
  start_port  = each.value
  end_port    = each.value
  cidr        = "0.0.0.0/0"
}

resource "exoscale_security_group_rule" "load_balancers_tcp6" {
  for_each = local.open_ports

  security_group_id = exoscale_security_group.load_balancers.id

  type        = "INGRESS"
  description = "${each.key} TCPv6"
  protocol    = "TCP"
  start_port  = each.value
  end_port    = each.value
  cidr        = "::/0"
}

resource "exoscale_security_group_rule" "load_balancers_udp4" {
  for_each = local.open_ports

  security_group_id = exoscale_security_group.load_balancers.id

  type        = "INGRESS"
  description = "${each.key} UDPv4"
  protocol    = "UDP"
  start_port  = each.value
  end_port    = each.value
  cidr        = "0.0.0.0/0"
}

resource "exoscale_security_group_rule" "load_balancers_udp6" {
  for_each = local.open_ports

  security_group_id = exoscale_security_group.load_balancers.id

  type        = "INGRESS"
  description = "${each.key} UDPv6"
  protocol    = "UDP"
  start_port  = each.value
  end_port    = each.value
  cidr        = "::/0"
}

resource "exoscale_security_group_rule" "load_balancers_machine_config_server" {
  count = length(data.exoscale_security_group.cluster)

  security_group_id = exoscale_security_group.load_balancers.id

  type        = "INGRESS"
  description = "Machine Config server from ${data.exoscale_security_group.cluster[count.index].name}"
  protocol    = "TCP"
  start_port  = "22623"
  end_port    = "22623"

  user_security_group_id = data.exoscale_security_group.cluster[count.index].id
}
