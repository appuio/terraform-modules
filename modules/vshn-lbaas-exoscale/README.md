# VSHN LBaaS for Exoscale

> :warning: **WIP**: This is still a work in progress and will change!

This repository provides a Terraform module to provision VSHN managed LBs for running Rancher or Openshift 4 clusters.

## Overview

The Terraform module in this repository provisions all the infrastructure which is required for running Rancher or Openshift 4 clusters behind VSHN managed LBs.

The module manages the VMs (cloud-init configs) and floating IPs for a highly-available OpenShift 4 cluster.

The LB VMs run Ubuntu LTS 22.04 and are managed and configured via the VSHN Puppet infrastructure.
Those VMs run HAproxy, keepalived, and [Floaty](https://github.com/vshn/floaty/) to provide a highly-available load balancer for the cluster.

By default, the module expects that clusters on Exoscale are provisioned with public interfaces and access is managed with Exoscale security groups.

### Module input variables

The module provides variables to

* control the count of LB VMs.
  Note that we don't recommend changing the count for the LBs from their default values.
* customize the instance type of the LB VMs (by default we provision "Medium" Exoscale instances).
* specify the cluster's id, Exoscale region, Exoscale-managed domain name, SSH key, api backends, router backends, and bootstrap node.
* specify an existing Exoscale managed private network and host for the internal VIP in that network.
* specify a list of security group ids which are allowed to access the LB's cluster-internal frontends.
* specify the username for the APPUiO hieradata Git repository (see next sections for details).
* specify the team to assign the LBs to in Icinga.
* provide an API token for control.vshn.net (see next sections for details).
* control whether HAproxy is configured to use PROXY protocol for the router backends
* provide a list of additional Exoscale private networks to attach to the LBs
* choose a dedicated deployment target

## Required credentials

* Exoscale IAM credentials for provisioning the Exoscale resources.
* An API token for the control.vshn.net Servers API must be created on [control.vshn.net](https://control.vshn.net/tokens/_create/servers)
* A project access token for the APPUiO hieradata repository must be created on [git.vshn.net](https://git.vshn.net/appuio/appuio_hieradata/-/settings/access_tokens)
  * The minimum required permissions for the project access token are `api` (to create MRs), `read_repository` (to clone the repo) and `write_repository` (to push to the repo).

## VSHN service dependencies

Since the module manages a VSHN-specific Puppet configuration for the LB VMs, it needs access to some [VSHN](https://www.vshn.ch) infrastructure:

* The module makes requests to the control.vshn.net [Servers API](https://control.docs.vshn.ch/control/api_servers.html) to register the LB VMs in VSHN's Puppet enc (external node classifier)
* The module needs access to the [APPUiO hieradata on git.vshn.net](https://git.vshn.net/appuio/appuio_hieradata) to create the appropriate configuration for the LBs

## Optional features

### Support for clusters provisioned in a private network

> :warning: Support for clusters provisioned in an Exoscale managed private network has not been tested.

The module has some logic for configuring LBs which are suitable for clusters which are provisioned in an Exoscale managed private network.

To configure the LBs for such a cluster, provide the following input:

```
cluster_network = {
  enabled           = true
  name              = exoscale_private_network.<resource>.name
  internal_vip_host = "100"
}
```

With this configuration, the module will setup the LBs to serve the Kubernetes and Machine Server config APIs in that network.
You can control the virtual IP for the API in the internal network with parameter `internal_vip_host`.
The module constructs the virtual IP for the API by generating the IP `<prefix>.100`, where `<prefix>` is the CIDR of the provided Exoscale managed network.

Additionally, when `cluster_network` is enabled, the LBs are configured as NAT gateways and provide `<prefix>.1` as the default gateway for the provided network.
Traffic on `<prefix>.1` is source-NATed and forwarded over the public interface on a separate VIP.
