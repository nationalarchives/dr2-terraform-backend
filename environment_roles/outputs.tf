output "terraform_role_arn" {
  value     = module.terraform_role.role_arn
  sensitive = true
}

output "copy_tna_to_preservica_role_arn" {
  value = module.copy_tna_to_preservica_role[*].role_arn
}
