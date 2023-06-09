locals {
  terraform_state_bucket_name = "mgmt-dp-terraform-state"
  environments                = toset(["intg", "staging", "prod"])
  environments_roles = {
    intg    = module.environment_roles_intg.role_arn
    staging = module.environment_roles_staging.role_arn
    prod    = module.environment_roles_prod.role_arn
  }

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
  source             = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_caller_identity.current.account_id, repo_filter = "dp-*" })
  name               = "MgmtDPTerraformGitHubRepositoriesRole"
  policy_attachments = {
    state_access_policy = module.terraform_github_repository_policy.policy_arn
    ssm_policy          = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  }
  tags = {}
}

module "terraform_github_repository_da_iam" {
  source             = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_caller_identity.current.account_id, repo_filter = "da-*" })
  name               = "MgmtDATerraformGitHubRepositoriesRole"
  policy_attachments = {
    state_access_policy = module.terraform_da_github_repository_policy.policy_arn
    ssm_policy          = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  }
  tags = {}
}

module "terraform_github_terraform_environments" {
  for_each           = local.environments
  source             = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_caller_identity.current.account_id, repo_filter = "dp-*" })
  name               = "MgmtDPGithubTerraformEnvironmentsRole${title(each.key)}"
  policy_attachments = {
    state_access_policy           = module.terraform_github_repository_policy.policy_arn
    terraform_environments_policy = module.terraform_github_terraform_environments_policy[each.key].policy_arn
  }
  tags = {}
}

module "terraform_github_terraform_environments_policy" {
  for_each = local.environments
  source   = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_policy"
  name     = "MgmtDPGithubTerraformEnvironmentsPolicy${each.key}"
  policy_string = templatefile("./templates/iam_policy/terraform_mgmt_assume_role.json.tpl", {
    role_arn   = local.environments_roles[each.key]
    account_id = data.aws_caller_identity.current.account_id
  })
}

module "terraform_github_repository_policy" {
  source        = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_policy"
  name          = "MgmtDPTerraformStateAccessPolicy"
  policy_string = templatefile("${path.module}/templates/iam_policy/terraform_state_access.json.tpl", { bucket_name = local.terraform_state_bucket_name, dynamo_table_arn = module.dp_terraform_dynamo.table_arn })
}

module "terraform_da_github_repository_policy" {
  source        = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_policy"
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

module "code_deploy_bucket" {
  source      = "git::https://github.com/nationalarchives/da-terraform-modules.git//s3"
  bucket_name = "mgmt-dp-code-deploy"
  bucket_policy = templatefile("${path.module}/templates/s3/code_deploy.json.tpl", {
    intg_account_number    = data.aws_ssm_parameter.intg_account_number.value,
    staging_account_number = data.aws_ssm_parameter.staging_account_number.value
    prod_account_number    = data.aws_ssm_parameter.prod_account_number.value
  })
  create_log_bucket = false
}
