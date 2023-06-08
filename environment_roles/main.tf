data "aws_caller_identity" "current" {}

module "terraform_role" {
  source             = "git::https://github.com/nationalarchives/da-terraform-modules//iam_role"
  assume_role_policy = templatefile("./templates/iam_role/account_assume_role.json.tpl", { account_id = var.management_account_number })
  name               = "${title(var.environment)}TerraformRole"
  policy_attachments = {
    terraform_policy = module.terraform_policy.policy_arn
  }
  tags = { CreatedBy = "dp-terraform-backend" }
}

module "terraform_policy" {
  source        = "git::https://github.com/nationalarchives/da-terraform-modules//iam_policy"
  name          = "${title(var.environment)}TerraformPolicy"
  policy_string = templatefile("./templates/iam_policy/terraform_policy.json.tpl", { account_id = var.account_number, environment = var.environment })
}


