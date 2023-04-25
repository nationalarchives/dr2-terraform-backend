locals {
  terraform_state_bucket_name = "mgmt-dp-terraform-state"
}
module "terraform_s3_bucket" {
  source                = "git::https://github.com/nationalarchives/da-terraform-modules.git//s3?ref=add-s3-module"
  bucket_name           = local.terraform_state_bucket_name
  bucket_policy         = templatefile("${path.module}/templates/s3/s3_secure_transport.json.tpl", { bucket_name = local.terraform_state_bucket_name })
  logging_bucket_policy = templatefile("${path.module}/templates/s3/s3_secure_transport_logging.json.tpl", { bucket_name = "${local.terraform_state_bucket_name}-logs" })
}

module "terraform_dynamo" {
  source        = "git::https://github.com/nationalarchives/da-terraform-modules.git//dynamo?ref=add-s3-module"
  hash_key      = "LockID"
  hash_key_type = "S"
  table_name    = "mgmt-dp-terraform-state-lock"
}

module "terraform_github_repository_iam" {
  source             = "git::https://github.com/nationalarchives/tdr-terraform-modules.git//iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", { account_id = data.aws_caller_identity.current.account_id, repo_filter = "dp-terraform-github-repositories" })
  common_tags        = {}
  name               = "MgmtDPTerraformGitHubRepositoriesRole"
  policy_attachments = {
    state_access_policy = module.terraform_github_repository_policy.policy_arn
  }
}

module "terraform_github_repository_policy" {
  source        = "git::https://github.com/nationalarchives/tdr-terraform-modules.git//iam_policy"
  name          = "MgmtDPTerraformGitHubRepositoriesPolicy"
  policy_string = templatefile("${path.module}/templates/iam_policy/terraform_state_access.json.tpl", { bucket_name = local.terraform_state_bucket_name })
}

module "github_oidc_provider" {
  source      = "git::https://github.com/nationalarchives/tdr-terraform-modules.git//identity_provider"
  audience    = "sts.amazonaws.com"
  thumbprint  = "6938fd4d98bab03faadb97b34396831e3780aea1"
  url         = "https://token.actions.githubusercontent.com"
  common_tags = {}
}
