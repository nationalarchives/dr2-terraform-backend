output "repository_environment_filters" {
  value = toset(flatten(values(local.environment_filters)))
}

output "repository_filters" {
  value = local.repository_branch_filters
}

output "repository_environments" {
  value = local.environment_filters
}


