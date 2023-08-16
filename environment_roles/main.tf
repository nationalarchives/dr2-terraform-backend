data "aws_caller_identity" "current" {}

module "terraform_role" {
  source             = "git::https://github.com/nationalarchives/da-terraform-modules//iam_role"
  assume_role_policy = templatefile("./templates/iam_role/account_assume_role.json.tpl", { account_id = var.management_account_number, external_id = var.terraform_external_id })
  name               = "${title(var.environment)}TerraformRole"
  policy_attachments = {
    terraform_policy = module.terraform_policy.policy_arn
  }
  tags = { CreatedBy = "dr2-terraform-backend" }
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

resource "aws_iam_openid_connect_provider" "openid_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
  url             = "https://token.actions.githubusercontent.com"
}
