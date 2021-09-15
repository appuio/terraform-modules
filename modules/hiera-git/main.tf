resource "gitfile_checkout" "appuio_hieradata" {
  repo = "https://${var.hieradata_repo_user}@git.vshn.net/appuio/appuio_hieradata.git"
  path = "${path.root}/appuio_hieradata"

  lifecycle {
    ignore_changes = [
      branch
    ]
  }
}

resource "local_file" "lb_hieradata" {
  content = var.content

  filename             = "${path.cwd}/appuio_hieradata/lbaas/${var.cluster_id}.yaml"
  file_permission      = "0644"
  directory_permission = "0755"

  depends_on = [
    gitfile_checkout.appuio_hieradata
  ]

  provisioner "local-exec" {
    command = "${path.module}/files/commit-hieradata.sh ${var.cluster_id} ${path.cwd}/.mr_url.txt"
  }
}

data "local_file" "hieradata_mr_url" {
  filename = "${path.cwd}/.mr_url.txt"

  depends_on = [
    local_file.lb_hieradata
  ]
}
