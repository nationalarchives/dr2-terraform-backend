locals {
  environment_filters = { for environment in var.environments : environment => concat(flatten([
    for repository in var.repositories : [
      "repo:${var.organisation}/${repository.name}:environment:${environment}"
    ]
    ]), local.repository_branch_filters)
  }
  repository_branch_filters = [
    for repository in var.repositories : flatten([
      "repo:${var.organisation}/${repository.name}:ref:refs/heads/${repository.branch}",
      "repo:${var.organisation}/${repository.name}:pull_request"
    ])
  ]
}