# VSHN LBaaS Hieradata Configuration

> :warning: **WIP**: This is still a work in progress and will change!

This repository provides a Terraform module to write [APPUiO hieradata to git.vshn.net](https://git.vshn.net/appuio/appuio_hieradata).

## Overview

The Terraform module in this repository generates, pushes, and opens MRs for APPUiO LBaaS hieradata configuration.

### Module input variables

The module provides variables to

* specify the cluster's id, base domain, SSH key, router backends, bootstrap node.
* specify virtual ips for:
  * the Kubernetes/OpenShift API in the internal network
  * the Kubernetes/OpenShift API
  * the source IP for the cluster's NATed egress traffic
  * the cluster's ingress controller/application router
* specify a Cloudscale API secret for Floaty
* specify the username for the APPUiO hieradata Git repository (see next sections for details).

## Required credentials

* A read/write Cloudscale API token in the project in which the cluster should be deployed for Floaty
* A project access token for the APPUiO hieradata repository must be created on [git.vshn.net](https://git.vshn.net/appuio/appuio_hieradata/-/settings/access_tokens)
  * The minimum required permissions for the project access token are `api` (to create MRs), `read_repository` (to clone the repo) and `write_repository` (to push to the repo).

## VSHN service dependencies

The module needs access to the [APPUiO hieradata on git.vshn.net](https://git.vshn.net/appuio/appuio_hieradata) to create the appropriate configuration for the LBs

## Optional features
