output "api_vip" {
  value = exoscale_elastic_ip.api.ip_address
}

output "router_vip" {
  value = exoscale_elastic_ip.ingress.ip_address
}

output "server_names" {
  value = random_id.lb[*].hex
}

output "private_ipv4_addresses" {
  value = exoscale_compute_instance.lb[*].network_interface[*].ip_address
}

output "public_ipv4_addresses" {
  value = exoscale_compute_instance.lb[*].public_ip_address
}

output "hieradata_mr_url" {
  value = module.hiera[*].hieradata_mr_url
}

output "security_group_name" {
  value = exoscale_security_group.load_balancers.name
}

output "internal_vip" {
  value = local.internal_vip
}
