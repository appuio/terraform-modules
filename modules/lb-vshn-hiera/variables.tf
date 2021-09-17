variable "router_ip_addresses" {
  type        = list(string)
  description = "Private IPV4 addresses of nodes running ingress routers"
}

variable "bootstrap_node" {
  type        = string
  description = "The bootstrap nodes private IPV4 adsress"
  default     = ""
}

variable "node_name_suffix" {
  type        = string
  description = "Suffix to use for node names"
}

variable "cluster_id" {
  type        = string
  description = "ID of the cluster"
}

variable "lb_names" {
  description = "The hostnames of the loadbalancers"
  type        = list(string)
}

variable "lb_cloudscale_api_secret" {
  type        = string
  description = "Read-Only API secret to access floating ips"
}

variable "hieradata_repo_user" {
  type        = string
  description = "User used to check out the hieradata git repo"
}

variable "internal_vip" {
  type        = string
  description = "Virtual IP for the Kubernetes/OpenShift API in the internal network"
  default     = ""
}

variable "api_vip" {
  type        = string
  description = "Floating IP for the Kubernetes/OpenShift API"
}

variable "nat_vip" {
  type        = string
  description = "Floating IP which is used as the source IP for the cluster's NATed egress traffic"
}

variable "router_vip" {
  type        = string
  description = "Floating IP for the cluster's ingress controller/application router"
}
