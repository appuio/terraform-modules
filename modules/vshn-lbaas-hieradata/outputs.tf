output "hieradata_mr_url" {
  value = local.lb_count > 0 ? data.local_file.hieradata_mr_url[0].content : ""
}
