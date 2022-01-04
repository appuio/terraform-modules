variable "cloud_provider" {
  type        = string
  description = "The cloud provider to generate the hieradata for."

  validation {
    condition     = var.cloud_provider == "cloudscale" || var.cloud_provider == "exoscale"
    error_message = "The vshn-lbaas-hieradata module currently only supports cloudscale.ch and Exoscale."
  }
}

variable "router_backends" {
  type        = list(string)
  description = "IP addresses or hostnames of nodes running ingress routers"
}

variable "api_backends" {
  type        = list(string)
  description = "IP addresses or hostnames of the Kubernetes/OpenShift API"
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

variable "lb_names" {
  description = "The hostnames of the loadbalancers"
  type        = list(string)
}

variable "lb_api_credentials" {
  type = object({
    cloudscale = optional(object({
      secret = string,
    })),
    exoscale = optional(object({
      key    = string,
      secret = string,
    }))
  })
  description = "API credentials for Floaty."

  validation {
    condition     = var.lb_api_credentials.cloudscale != null || var.lb_api_credentials.exoscale != null
    error_message = "You *MUST* configure either cloudscale.ch or Exoscale API credentials."
  }
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

variable "team" {
  type        = string
  description = "Team to assign the load balancers to in Icinga. All lower case."
}

variable "enable_proxy_protocol" {
  type        = bool
  description = "Enable the PROXY protocol for the Router backends. WARNING: Connections will fail until you enable the same on the OpenShift router as well"
  default     = false
}
