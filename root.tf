locals {
  terraform_state_bucket_name = "mgmt-dp-terraform-state"
}
module "terraform_s3_bucket" {
  source                = "git::https://github.com/nationalarchives/da-terraform-modules.git//s3"
  bucket_name           = local.terraform_state_bucket_name
  bucket_policy         = templatefile("${path.module}/templates/s3/s3_secure_transport_logging.json.tpl", { bucket_name = local.terraform_state_bucket_name })
  logging_bucket_policy = templatefile("${path.module}/templates/s3/s3_secure_transport_logging.json.tpl", { bucket_name = "${local.terraform_state_bucket_name}-logs" })
}

module "da_terraform_dynamo" {
  source        = "git::https://github.com/nationalarchives/da-terraform-modules.git//dynamo"
  hash_key      = "LockID"
  hash_key_type = "S"
  table_name    = "mgmt-da-terraform-state-lock"
}

module "dp_terraform_dynamo" {
  source        = "git::https://github.com/nationalarchives/da-terraform-modules.git//dynamo"
  hash_key      = "LockID"
  hash_key_type = "S"
  table_name    = "mgmt-dp-terraform-state-lock"
}

module "terraform_github_repository_iam" {
  source             = "git::https://github.com/nationalarchives/tdr-terraform-modules.git//iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_caller_identity.current.account_id, repo_filter = "dp-*" })
  common_tags        = {}
  name               = "MgmtDPTerraformGitHubRepositoriesRole"
  policy_attachments = {
    state_access_policy = module.terraform_github_repository_policy.policy_arn
    ssm_policy          = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  }
}

module "terraform_github_repository_da_iam" {
  source             = "git::https://github.com/nationalarchives/tdr-terraform-modules.git//iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_caller_identity.current.account_id, repo_filter = "da-*" })
  common_tags        = {}
  name               = "MgmtDATerraformGitHubRepositoriesRole"
  policy_attachments = {
    state_access_policy = module.terraform_da_github_repository_policy.policy_arn
    ssm_policy          = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  }
}

module "terraform_github_terraform_environments" {
  source             = "git::https://github.com/nationalarchives/tdr-terraform-modules.git//iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_caller_identity.current.account_id, repo_filter = "dp-*" })
  common_tags        = {}
  name               = "MgmtDPGithubTerraformEnvironmentsRole"
  policy_attachments = {
    state_access_policy           = module.terraform_github_repository_policy.policy_arn
    terraform_environments_policy = module.terraform_github_terraform_environments_policy.policy_arn
  }
}

module "terraform_github_terraform_environments_policy" {
  source = "git::https://github.com/nationalarchives/tdr-terraform-modules.git//iam_policy"
  name   = "MgmtDPGithubTerraformEnvironmentsPolicy"
  policy_string = templatefile("./templates/iam_policy/terraform_mgmt_assume_role.json.tpl", {
    intg_role_arn    = module.environment_roles_intg.role_arn
    staging_role_arn = module.environment_roles_staging.role_arn
    prod_role_arn    = module.environment_roles_prod.role_arn
  })
}

module "terraform_github_repository_policy" {
  source        = "git::https://github.com/nationalarchives/tdr-terraform-modules.git//iam_policy"
  name          = "MgmtDPTerraformGitHubRepositoriesPolicy"
  policy_string = templatefile("${path.module}/templates/iam_policy/terraform_state_access.json.tpl", { bucket_name = local.terraform_state_bucket_name, dynamo_table_arn = module.dp_terraform_dynamo.table_arn })
}



module "terraform_da_github_repository_policy" {
  source        = "git::https://github.com/nationalarchives/tdr-terraform-modules.git//iam_policy"
  name          = "MgmtDATerraformGitHubRepositoriesPolicy"
  policy_string = templatefile("${path.module}/templates/iam_policy/terraform_state_access.json.tpl", { bucket_name = local.terraform_state_bucket_name, dynamo_table_arn = module.da_terraform_dynamo.table_arn })
}

module "github_oidc_provider" {
  source      = "git::https://github.com/nationalarchives/tdr-terraform-modules.git//identity_provider"
  audience    = "sts.amazonaws.com"
  thumbprint  = "6938fd4d98bab03faadb97b34396831e3780aea1"
  url         = "https://token.actions.githubusercontent.com"
  common_tags = {}
}


module "environment_roles_intg" {
  providers = {
    aws = aws.intg
  }
  source                    = "./environment_roles"
  account_number            = data.aws_ssm_parameter.intg_account_number.value
  environment               = "intg"
  management_account_number = data.aws_caller_identity.current.account_id
}

module "environment_roles_staging" {
  providers = {
    aws = aws.staging
  }
  source                    = "./environment_roles"
  account_number            = data.aws_ssm_parameter.staging_account_number.value
  environment               = "staging"
  management_account_number = data.aws_caller_identity.current.account_id
}

module "environment_roles_prod" {
  providers = {
    aws = aws.prod
  }
  source                    = "./environment_roles"
  account_number            = data.aws_ssm_parameter.prod_account_number.value
  environment               = "prod"
  management_account_number = data.aws_caller_identity.current.account_id
}
