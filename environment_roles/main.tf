data "aws_caller_identity" "current" {}

locals {
  preservica_tenant           = var.environment == "prod" ? "tna" : "tnatest"
  tna_to_preservica_role_name = "${var.environment}-tna-to-preservica-ingest-s3-${local.preservica_tenant}"
  tna_to_preservica_role_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.tna_to_preservica_role_name}"
}

module "terraform_role" {
  source = "git::https://github.com/nationalarchives/da-terraform-modules//iam_role"
  assume_role_policy = templatefile("./templates/iam_role/account_assume_role.json.tpl", {
    admin_role_arn = data.aws_ssm_parameter.dev_admin_role.value
    account_id     = var.account_number,
    repo_filters   = var.terraform_repository_filters
  })
  name = "${title(var.environment)}TerraformRole"
  policy_attachments = {
    terraform_policy = module.terraform_policy.policy_arn
  }
  tags = { CreatedBy = "dr2-terraform-backend" }
}

module "terraform_policy" {
  source        = "git::https://github.com/nationalarchives/da-terraform-modules//iam_policy"
  name          = "${title(var.environment)}TerraformPolicy"
  policy_string = templatefile("./templates/iam_policy/terraform_policy.json.tpl", { account_id = var.account_number, environment = var.environment, environment_title = title(var.environment), management_account_id = var.management_account_number })
}

module "custodian_repo_filters" {
  source       = "../github_repository_filters"
  repositories = [{ name : "tna-custodian", "branch" : "master" }]
  environments = ["dr2-intg", "dr2-staging", "dr2-prod", "dr2-mgmt"]
}

module "custodian_role" {
  source = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_role"
  assume_role_policy = templatefile("${path.root}/templates/iam_role/github_assume_role.json.tpl", {
    account_id   = data.aws_caller_identity.current.account_id,
    repo_filters = jsonencode(module.custodian_repo_filters.repository_environments["dr2-${var.environment}"])
  })
  name = "${title(var.environment)}DR2GithubActionsCustodianDeployRole"
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

module "business_analyst_policy" {
  count         = var.environment == "intg" ? 1 : 0
  source        = "git::https://github.com/nationalarchives/da-terraform-modules//iam_policy"
  name          = "AWSSSO_DABusinessAnalyst"
  policy_string = templatefile("./templates/iam_policy/business_analyst_policy.json.tpl", { account_id = var.account_number, environment = var.environment })
}

resource "aws_cloudwatch_log_group" "terraform_plan_log_group" {
  name = "terraform-plan-outputs-${var.environment}"
}

data "aws_ssm_parameter" "dev_admin_role" {
  name = "/${var.environment}/developer_role"
}

