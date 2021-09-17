module "git" {
  source = "./modules/git"

  count = local.lb_count > 0 ? 1 : 0

  hieradata_repo_user = var.hieradata_repo_user
  cluster_id          = var.cluster_id
  content             = local.content
}
