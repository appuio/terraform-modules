resource "exoscale_security_group" "load_balancers" {
  name        = "${var.cluster_id}_load_balancers"
  description = "${var.cluster_id} load balancer VMs"
}

resource "exoscale_security_group_rules" "load_balancers" {
  security_group = exoscale_security_group.load_balancers.name
  ingress {
    description = "Kubernetes API"
    protocol    = "TCP"
    ports       = ["6443"]
    cidr_list   = ["0.0.0.0/0", "::/0"]
  }
  ingress {
    description = "Ingress controller TCP"
    protocol    = "TCP"
    ports       = ["80", "443"]
    cidr_list   = ["0.0.0.0/0", "::/0"]
  }
  ingress {
    description = "Ingress controller UDP"
    protocol    = "UDP"
    ports       = ["80", "443"]
    cidr_list   = ["0.0.0.0/0", "::/0"]
  }
  ingress {
    description              = "Machine Config server"
    protocol                 = "TCP"
    ports                    = ["22623"]
    user_security_group_list = var.cluster_security_group_names
  }
}
