output "terraform_role_arn" {
  value     = module.terraform_role.role_arn
  sensitive = true
}
