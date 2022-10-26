variable "exoscale_domain_name" {
  type        = string
  description = "Exoscale-managed cluster domain name"
}

variable "cluster_network" {
  type = object({
    enabled           = bool
    name              = string
    internal_vip_host = string
  })
  description = "Set this to `enabled=true` and the name of an existing Exoscale private network to use that network as the LB private network."
  default = {
    enabled           = false
    name              = ""
    internal_vip_host = "100"
  }
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

variable "cluster_security_group_names" {
  type        = list(string)
  description = "Security group names for which the LBs should allow traffic on the Machine Config server port"

  validation {
    condition     = length(var.cluster_security_group_names) > 0
    error_message = "You must specify at least one cluster security group."
  }
}

variable "ssh_key_name" {
  type        = string
  description = "Name of an SSH key configured on Exoscale to add to the LBs"
}

variable "lb_count" {
  type        = number
  default     = 2
  description = "The number of loadbalancers to create"
}

variable "lb_type" {
  type        = string
  default     = "standard.medium"
  description = "The instance type to use for the LBs"
}

variable "control_vshn_net_token" {
  type        = string
  description = "The token is used to register the server with https://control.vshn.net/"
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
  description = "The bootstrap node's private IPV4 adsress"
  default     = ""
}

variable "team" {
  type        = string
  description = "Team to assign the load balancers to in Icinga. All lower case."
}

variable "additional_networks" {
  type        = list(string)
  description = "List of UUIDs of additional Exoscale networks to attach"
  default     = []
}

variable "enable_proxy_protocol" {
  type        = bool
  description = "Enable the PROXY protocol for the Router backends. WARNING: Connections will fail until you enable the same on the OpenShift router as well"
  default     = false
}

variable "additional_affinity_group_ids" {
  type        = list(string)
  default     = []
  description = "List of additional affinity group IDs to configure on all lbs"
}

variable "deploy_target_id" {
  type        = string
  default     = ""
  description = "ID of special deployment target, eg. dedicated hypervisors"
}
