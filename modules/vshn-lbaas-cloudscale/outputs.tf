output "api_vip" {
  value = local.api_vip
}

output "nat_vip" {
  value = local.nat_vip
}

output "router_vip" {
  value = local.router_vip
}

output "server_names" {
  value = random_id.lb[*].hex
}

output "private_ipv4_addresses" {
  value = cloudscale_server.lb[*].private_ipv4_address
}

output "public_ipv4_addresses" {
  value = cloudscale_server.lb[*].public_ipv4_address
}

output "hieradata_mr_url" {
  value = module.hiera[*].hieradata_mr_url
}
