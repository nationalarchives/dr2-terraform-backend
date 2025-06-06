output "terraform_role_arn" {
  value     = var.environment == "mgmt" ? "" : module.terraform_role[0].role_arn
  sensitive = true
}
