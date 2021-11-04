variable "node_name_suffix" {
  type        = string
  description = "Suffix to use for node names"
}

variable "cluster_id" {
  type        = string
  description = "ID of the cluster"
}

variable "distribution" {
  type        = string
  description = "The K8s distribution running on the cluster"
  default     = ""
}

variable "ingress_controller" {
  type        = string
  description = "The ingress controller running on the cluster"
  default     = ""
}

variable "region" {
  type        = string
  description = "Region where to deploy nodes"
}

variable "ssh_keys" {
  type        = list(string)
  description = "SSH keys to add to LBs"
  default     = []

  validation {
    condition     = length(var.ssh_keys) > 0
    error_message = "You must specify at least one SSH key for the LBs."
  }
}

variable "privnet_id" {
  description = "UUID of the private net to use"
}

variable "lb_count" {
  type        = number
  default     = 2
  description = "The number of loadbalancers to create"
}

variable "control_vshn_net_token" {
  type        = string
  description = "The token is used to register the server with https://control.vshn.net/"
}

variable "lb_cloudscale_api_secret" {
  type        = string
  description = "Read/Write API secret for Floaty"
}

variable "hieradata_repo_user" {
  type        = string
  description = "User used to check out the hieradata git repo"
}

variable "api_backends" {
  type        = list(string)
  description = "IP addresses or hostnames of nodes hosting the control plane"
  default     = []
}

variable "router_backends" {
  type        = list(string)
  description = "IP addresses or hostnames of nodes running ingress routers"
}

variable "bootstrap_node" {
  type        = string
  description = "The bootstrap nodes private IPV4 adsress"
  default     = ""
}

variable "internal_vip" {
  type        = string
  description = "Virtual IP for the Kubernetes/OpenShift API in the internal network"
  default     = ""
}

variable "team" {
  type        = string
  description = "Team to assign the load balancers to in Icinga. All lower case."
}

variable "additional_networks" {
  type        = list(string)
  description = "List of UUIDs of additional cloudscale.ch networks to attach"
  default     = []
}
