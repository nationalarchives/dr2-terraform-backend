data "aws_caller_identity" "current" {}

module "terraform_role" {
  source             = "git::https://github.com/nationalarchives/da-terraform-modules//iam_role"
  assume_role_policy = templatefile("./templates/iam_role/account_assume_role.json.tpl", { account_id = var.management_account_number, external_id = var.terraform_external_id })
  name               = "${title(var.environment)}TerraformRole"
  policy_attachments = {
    terraform_policy = module.terraform_policy.policy_arn
  }
  tags = { CreatedBy = "dp-terraform-backend" }
}

module "terraform_policy" {
  source        = "git::https://github.com/nationalarchives/da-terraform-modules//iam_policy"
  name          = "${title(var.environment)}TerraformPolicy"
  policy_string = templatefile("./templates/iam_policy/terraform_policy.json.tpl", { account_id = var.account_number, environment = var.environment, environment_title = title(var.environment) })
}

module "custodian_role" {
  source             = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_role"
  assume_role_policy = templatefile("${path.root}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_caller_identity.current.account_id, repo_filter = "tna-*" })
  name               = "${title(var.environment)}DR2GithubActionsCustodianDeployRole"
  policy_attachments = {
    custodian_policy = module.custodian_policy.policy_arn
  }
  tags = {}
}

module "custodian_policy" {
  source        = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_policy"
  name          = "${title(var.environment)}DR2GithubActionsCustodianDeploy"
  policy_string = templatefile("${path.root}/templates/iam_policy/custodian.json.tpl", { environment = var.environment, account_id = data.aws_caller_identity.current.account_id })
}

module "github_oidc_provider" {
  source      = "git::https://github.com/nationalarchives/tdr-terraform-modules.git//identity_provider"
  audience    = "sts.amazonaws.com"
  thumbprint  = "6938fd4d98bab03faadb97b34396831e3780aea1"
  url         = "https://token.actions.githubusercontent.com"
  common_tags = {}
}
