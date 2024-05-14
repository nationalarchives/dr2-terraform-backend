data "aws_caller_identity" "current" {}

locals {
  preservica_tenant           = var.environment == "prod" ? "tna" : "tnatest"
  tna_to_preservica_role_name = "${var.environment}-tna-to-preservica-ingest-s3-${local.preservica_tenant}"
  tna_to_preservica_role_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.tna_to_preservica_role_name}"
}

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

module "custodian_repo_filters" {
  source       = "../github_repository_filters"
  repositories = [{ name : "tna-custodian", "default_branch" : "master" }]
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

module "copy_tna_to_preservica_role" {
  count  = var.environment == "mgmt" ? 0 : 1
  source = "git::https://github.com/nationalarchives/da-terraform-modules//iam_role"
  assume_role_policy = templatefile("./templates/iam_role/tna_to_preservica_trust_policy.json.tpl", {
    terraform_role_arn        = module.terraform_role.role_arn,
    account_id                = data.aws_caller_identity.current.account_id,
    admin_role_arn            = var.management_developer_role_arn
    terraform_github_role_arn = var.terraform_github_role_arn
    title_environment         = title(var.environment)
    environment               = var.environment
  })
  name = local.tna_to_preservica_role_name
  policy_attachments = {
    copy_tna_to_preservica_policy = module.copy_tna_to_preservica_policy[count.index].policy_arn
  }
  tags = {}
}

module "copy_tna_to_preservica_policy" {
  count  = var.environment == "mgmt" ? 0 : 1
  source = "git::https://github.com/nationalarchives/da-terraform-modules//iam_policy"
  name   = "${var.environment}-tna-to-preservica-ingest-s3-${var.environment == "prod" ? "tna" : "tnatest"}-policy"
  policy_string = templatefile("./templates/iam_policy/tna_to_preservica_copy.json.tpl", {
    account_id                       = data.aws_caller_identity.current.account_id
    preservica_tenant                = local.preservica_tenant
    ingest_staging_cache_bucket_name = "${var.environment}-dr2-ingest-staging-cache",
    tna_to_preservica_role_arn       = local.tna_to_preservica_role_arn
  })
}

