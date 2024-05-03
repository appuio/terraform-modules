# VSHN LBaaS for cloudscale.ch

> :warning: **WIP**: This is still a work in progress and will change!

This repository provides a Terraform module to provision VSHN managed LBs for running Rancher or Openshift 4 clusters.

## Overview

The Terraform module in this repository provisions all the infrastructure which is required for running Rancher or Openshift 4 clusters behind VSHN managed LBs.

The module manages the VMs (cloud-init configs) and floating IPs for a highly-available OpenShift 4 cluster.

The LB VMs run Ubuntu LTS 20.04 and are managed and configured via the VSHN Puppet infrastructure.
Those VMs run HAproxy, keepalived, and [Floaty](https://github.com/vshn/floaty/) to provide a highly-available load balancer for the cluster.

### Module input variables

The module provides variables to

* control the count of LB VMs.
  Note that we don't recommend changing the count for the LBs from their default values.
* specify the cluster's id, cloudscale.ch region, base domain, SSH key, router backends, bootstrap node, virtual ip for the Kubernetes API in the internal network.
* specify a cloudscale.ch API secret for Floaty
* specify the username for the APPUiO hieradata Git repository (see next sections for details).
* provide an API token for control.vshn.net (see next sections for details).
* use pre-existing cloudscale floating IPs for api, ingress and egress.

## Required credentials

* A read/write cloudscale.ch API token in the project in which the cluster should be deployed
* A read/write cloudscale.ch API token in the same project for Floaty
* An API token for the control.vshn.net Servers API must be created on [control.vshn.net](https://control.vshn.net/tokens/_create/servers)
* A project access token for the APPUiO hieradata repository must be created on [git.vshn.net](https://git.vshn.net/appuio/appuio_hieradata/-/settings/access_tokens)
  * The minimum required permissions for the project access token are `api` (to create MRs), `read_repository` (to clone the repo) and `write_repository` (to push to the repo).

## VSHN service dependencies

Since the module manages a VSHN-specific Puppet configuration for the LB VMs, it needs access to some [VSHN](https://www.vshn.ch) infrastructure:

* The module makes requests to the control.vshn.net [Servers API](https://control.docs.vshn.ch/control/api_servers.html) to register the LB VMs in VSHN's Puppet enc (external node classifier)
* The module needs access to the [APPUiO hieradata on git.vshn.net](https://git.vshn.net/appuio/appuio_hieradata) to create the appropriate configuration for the LBs

## Optional features
