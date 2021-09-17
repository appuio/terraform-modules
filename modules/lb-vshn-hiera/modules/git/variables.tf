variable "cluster_id" {
  type        = string
  description = "ID of the cluster"
}

variable "hieradata_repo_user" {
  type = string
}

variable "content" {
  type        = string
  description = "Content of the hieradata file to commit. Should be yaml"
}
