output "repository_filters" {
  value = toset(flatten(values(local.environment_filters)))
}

output "repository_environments" {
  value = local.environment_filters
}


