locals {
  terraform_state_bucket_name  = "mgmt-dp-terraform-state"
  code_deploy_bucket_name      = "mgmt-dp-code-deploy"
  environments                 = toset(["intg", "staging", "prod"])
  dev_notifications_channel_id = "C052LJASZ08"
  department_terraform_repositories = [
    { name : "tna-custodian", branch : "master" },
    { name : "tdr-aws-accounts", branch : "master" }
  ]
  department_terraform_github_environments = [
    "dr2-intg",
    "dr2-staging",
    "dr2-prod",
    "dr2-mgmt"
  ]
  dr2_terraform_repositories = [
    { name : "dr2-terraform-environments", branch = "*" }
  ]
  dr2_terraform_github_environments = [
    "intg",
    "staging",
    "prod",
    "sbox",
    "mgmt"
  ]
  dr2_code_deploy_repositories  = [{ name : "dr2-ingest" }, { name : "dr2-ip-lock-checker" }]
  dr2_code_deploy_environments  = ["intg", "staging", "prod"]
  dr2_image_deploy_repositories = [{ name : "dr2-e2e-tests" }, { name : "dr2-court-document-package-anonymiser" }, { name : "dr2-disaster-recovery" }]
  environments_roles = {
    intg    = module.environment_roles_intg.terraform_role_arn
    staging = module.environment_roles_staging.terraform_role_arn
    prod    = module.environment_roles_prod.terraform_role_arn
  }
}

module "department_terraform_repository_filters" {
  source       = "./github_repository_filters"
  repositories = local.department_terraform_repositories
  environments = local.department_terraform_github_environments
}

module "dr2_terraform_repository_filters" {
  source       = "./github_repository_filters"
  repositories = local.dr2_terraform_repositories
  environments = local.dr2_terraform_github_environments
}

module "dr2_code_deploy_repository_filters" {
  source       = "./github_repository_filters"
  repositories = local.dr2_code_deploy_repositories
  environments = local.dr2_code_deploy_environments
}

module "dr2_image_deploy_repository_filters" {
  source       = "./github_repository_filters"
  repositories = local.dr2_image_deploy_repositories
  environments = local.dr2_code_deploy_environments
}

module "terraform_config" {
  source  = "./da-terraform-configurations/"
  project = "dr2"
}

module "terraform_s3_bucket" {
  source                = "git::https://github.com/nationalarchives/da-terraform-modules.git//s3"
  bucket_name           = local.terraform_state_bucket_name
  bucket_policy         = templatefile("${path.module}/templates/s3/s3_secure_transport_logging.json.tpl", { bucket_name = local.terraform_state_bucket_name })
  logging_bucket_policy = templatefile("${path.module}/templates/s3/s3_secure_transport_logging.json.tpl", { bucket_name = "${local.terraform_state_bucket_name}-logs" })
}

module "da_terraform_dynamo" {
  source     = "git::https://github.com/nationalarchives/da-terraform-modules.git//dynamo"
  hash_key   = { type = "S", name = "LockID" }
  table_name = "mgmt-da-terraform-state-lock"
}

module "dp_terraform_dynamo" {
  source     = "git::https://github.com/nationalarchives/da-terraform-modules.git//dynamo"
  hash_key   = { type = "S", name = "LockID" }
  table_name = "mgmt-dp-terraform-state-lock"
}

module "terraform_github_repository_iam" {
  source = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", {
    account_id = data.aws_caller_identity.current.account_id,
    repo_filters = jsonencode([
      "repo:nationalarchives/dr2-terraform-github-repositories:pull_request",
      "repo:nationalarchives/dr2-terraform-github-repositories:ref:refs/heads/main"
    ])
  })
  name = "MgmtDPTerraformGitHubRepositoriesRole"
  policy_attachments = {
    state_access_policy = module.terraform_github_repository_policy.policy_arn
    ssm_policy          = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  }
  tags = {}
}

module "terraform_github_repository_da_iam" {
  source = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", {
    account_id   = data.aws_caller_identity.current.account_id,
    repo_filters = jsonencode(["repo:nationalarchives/da-terraform-github-repositories:ref:refs/heads/main"])
  })
  name = "MgmtDATerraformGitHubRepositoriesRole"
  policy_attachments = {
    state_access_policy = module.terraform_da_github_repository_policy.policy_arn
    ssm_policy          = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  }
  tags = {}
}

module "terraform_github_terraform_environments" {
  for_each = local.environments
  source   = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", {
    account_id = data.aws_caller_identity.current.account_id,
    repo_filters = jsonencode(concat(
      module.department_terraform_repository_filters.repository_environments["dr2-${each.key}"],
      module.dr2_terraform_repository_filters.repository_environments[each.key]
    ))
  })
  name = "MgmtDPGithubTerraformEnvironmentsRole${title(each.key)}"
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
    terraform_role_arn               = local.environments_roles[each.key]
    preservica_copy_role_intg_arn    = module.environment_roles_intg.copy_tna_to_preservica_role_arn[0]
    preservica_copy_role_staging_arn = module.environment_roles_staging.copy_tna_to_preservica_role_arn[0]
    preservica_copy_role_prod_arn    = module.environment_roles_prod.copy_tna_to_preservica_role_arn[0]
    account_id                       = data.aws_caller_identity.current.account_id
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

module "environment_roles_intg" {
  providers = {
    aws = aws.intg
  }
  source                        = "./environment_roles"
  account_number                = data.aws_ssm_parameter.intg_account_number.value
  environment                   = "intg"
  management_account_number     = data.aws_caller_identity.current.account_id
  terraform_external_id         = module.terraform_config.terraform_config["intg"]["terraform_external_id"]
  terraform_github_role_arn     = module.terraform_github_terraform_environments["intg"].role_arn
  management_developer_role_arn = data.aws_ssm_parameter.dev_admin_role.value
}

module "environment_roles_staging" {
  providers = {
    aws = aws.staging
  }
  source                        = "./environment_roles"
  account_number                = data.aws_ssm_parameter.staging_account_number.value
  environment                   = "staging"
  management_account_number     = data.aws_caller_identity.current.account_id
  terraform_external_id         = module.terraform_config.terraform_config["staging"]["terraform_external_id"]
  terraform_github_role_arn     = module.terraform_github_terraform_environments["staging"].role_arn
  management_developer_role_arn = data.aws_ssm_parameter.dev_admin_role.value
}

module "environment_roles_prod" {
  providers = {
    aws = aws.prod
  }
  source                        = "./environment_roles"
  account_number                = data.aws_ssm_parameter.prod_account_number.value
  environment                   = "prod"
  management_account_number     = data.aws_caller_identity.current.account_id
  terraform_external_id         = module.terraform_config.terraform_config["prod"]["terraform_external_id"]
  terraform_github_role_arn     = module.terraform_github_terraform_environments["prod"].role_arn
  management_developer_role_arn = data.aws_ssm_parameter.dev_admin_role.value
}

module "environment_roles_mgmt" {
  source                        = "./environment_roles"
  account_number                = data.aws_caller_identity.current.account_id
  environment                   = "mgmt"
  management_account_number     = data.aws_caller_identity.current.account_id
  terraform_external_id         = module.terraform_config.terraform_config["mgmt"]["terraform_external_id"]
  terraform_github_role_arn     = module.terraform_github_repository_iam.role_arn
  management_developer_role_arn = data.aws_ssm_parameter.dev_admin_role.value
}

module "code_deploy_bucket" {
  source      = "git::https://github.com/nationalarchives/da-terraform-modules.git//s3"
  bucket_name = local.code_deploy_bucket_name
  bucket_policy = templatefile("${path.module}/templates/s3/code_deploy.json.tpl", {
    intg_account_number    = data.aws_ssm_parameter.intg_account_number.value,
    staging_account_number = data.aws_ssm_parameter.staging_account_number.value
    prod_account_number    = data.aws_ssm_parameter.prod_account_number.value
  })
  create_log_bucket = false
}

module "code_build_role" {
  source = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", {
    account_id   = data.aws_caller_identity.current.account_id,
    repo_filters = jsonencode(module.dr2_code_deploy_repository_filters.repository_environment_filters)
  })
  name = "MgmtDPGithubCodeDeploy"
  policy_attachments = {
    code_upload_policy = module.code_build_policy.policy_arn
  }
  tags = {}
}

module "code_build_policy" {
  source        = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_policy"
  name          = "MgmtDPGithubCodeDeployPolicy"
  policy_string = templatefile("${path.module}/templates/iam_policy/code_build.json.tpl", { code_deploy_bucket = local.code_deploy_bucket_name })
}

resource "aws_cloudwatch_log_group" "terraform_log_group" {
  for_each          = local.environments
  name              = "terraform-plan-outputs-${each.key}"
  retention_in_days = 7
}

resource "aws_ecrpublic_repository" "judgment_package_anonymiser" {
  provider        = aws.us_east_1
  repository_name = "anonymiser"

  catalog_data {
    architectures     = ["ARM"]
    description       = "This image takes production judgment packages from TRE and anonymises them"
    operating_systems = ["Linux"]
  }
}

resource "aws_ecr_registry_scanning_configuration" "enhanced_scanning" {
  scan_type = "ENHANCED"
}

module "e2e_tests_repository" {
  source          = "git::https://github.com/nationalarchives/da-terraform-modules.git//ecr"
  repository_name = "e2e-tests"
  repository_policy = templatefile("${path.module}/templates/ecr/cross_account_repository_policy.json.tpl", {
    allowed_principals = jsonencode([
      "arn:aws:iam::${data.aws_ssm_parameter.intg_account_number.value}:role/intg-dr2-e2e-tests-execution-role",
      "arn:aws:iam::${data.aws_ssm_parameter.staging_account_number.value}:role/staging-dr2-e2e-tests-execution-role"
    ]),
    account_number = data.aws_caller_identity.current.account_id
  })
}

module "disaster_recovery_repository" {
  source          = "git::https://github.com/nationalarchives/da-terraform-modules.git//ecr"
  repository_name = "dr2-disaster-recovery"
  repository_policy = templatefile("${path.module}/templates/ecr/cross_account_repository_policy.json.tpl", {
    allowed_principals = jsonencode([
      "arn:aws:iam::${data.aws_ssm_parameter.intg_account_number.value}:user/intg-dr2-disaster-recovery",
      "arn:aws:iam::${data.aws_ssm_parameter.staging_account_number.value}:user/staging-dr2-disaster-recovery",
      "arn:aws:iam::${data.aws_ssm_parameter.prod_account_number.value}:user/prod-dr2-disaster-recovery"
    ]),
    account_number = data.aws_caller_identity.current.account_id
  })
}

module "image_deploy_role" {
  source = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam_role/github_assume_role.json.tpl", {
    account_id   = data.aws_caller_identity.current.account_id,
    repo_filters = jsonencode(module.dr2_image_deploy_repository_filters.repository_environment_filters)
  })
  name = "MgmtDPGithubImageDeploy"
  policy_attachments = {
    image_deploy_policy = module.image_deploy_policy.policy_arn
  }
  tags = {}
}

module "image_deploy_policy" {
  source        = "git::https://github.com/nationalarchives/da-terraform-modules.git//iam_policy"
  name          = "MgmtDPGithubImageDeployPolicy"
  policy_string = templatefile("${path.module}/templates/iam_policy/image_deploy.json.tpl", {})
}

module "eventbridge_alarm_notifications_destination" {
  source                     = "git::https://github.com/nationalarchives/da-terraform-modules//eventbridge_api_destination"
  authorisation_header_value = "Bearer ${data.aws_ssm_parameter.slack_token.value}"
  name                       = "mgmt-eventbridge-slack-destination"
}

module "image_scan_vulnerability_alerts" {
  source              = "git::https://github.com/nationalarchives/da-terraform-modules//eventbridge_api_destination_rule"
  event_pattern       = templatefile("${path.module}/templates/eventbridge/image_scan_vulnerability_event_pattern.json.tpl", {})
  name                = "mgmt-eventbridge-image-scan-vulnerabilities"
  api_destination_arn = module.eventbridge_alarm_notifications_destination.api_destination_arn
  api_destination_input_transformer = {
    input_paths = {
      "repositoryName" = "$.detail.repository-name"
    }
    input_template = templatefile("${path.module}/templates/eventbridge/slack_message_input_template.json.tpl", {
      channel_id   = data.aws_ssm_parameter.dr2_notifications_slack_channel.value
      slackMessage = ":alert-noflash-slow: Vulnerabilities found in the <repositoryName> image. Log into ECR in the management account for more details"
    })
  }
}

module "enhanced_scanning_inspector_findings_alerts" {
  source = "git::https://github.com/nationalarchives/da-terraform-modules//eventbridge_api_destination_rule"
  event_pattern = templatefile("${path.module}/templates/eventbridge/generic_event_pattern.json.tpl", {
    source      = "aws.inspector2",
    detail_type = "Inspector2 Finding"
  })
  name                = "mgmt-ecr-inspector-findings"
  api_destination_arn = module.eventbridge_alarm_notifications_destination.api_destination_arn
  api_destination_input_transformer = {
    input_paths = {
      "vulnerabilityId" : "$.detail.packageVulnerabilityDetails.vulnerabilityId",
      "repositoryName" : "$.detail.resources[0].details.awsEcrContainerImage.repositoryName",
      "severity" : "$.detail.severity"
    }
    input_template = templatefile("${path.module}/templates/eventbridge/slack_message_input_template.json.tpl", {
      channel_id   = local.dev_notifications_channel_id
      slackMessage = ":alert-noflash-slow: Vulnerability <vulnerabilityId> with <severity> severity found in repository <repositoryName>"
    })
  }
}

module "enhanced_scanning_inspector_initial_scan_alert" {
  source = "git::https://github.com/nationalarchives/da-terraform-modules//eventbridge_api_destination_rule"
  event_pattern = templatefile("${path.module}/templates/eventbridge/generic_event_pattern.json.tpl", {
    source      = "aws.inspector2",
    detail_type = "Inspector2 Scan"
  })
  name                = "mgmt-ecr-inspector-initial-scan"
  api_destination_arn = module.eventbridge_alarm_notifications_destination.api_destination_arn
  api_destination_input_transformer = {
    input_paths = {
      "totalFindings" : "$.detail.finding-severity-counts.TOTAL",
      "repositoryName" : "$.detail.repository-name"
    }
    input_template = templatefile("${path.module}/templates/eventbridge/slack_message_input_template.json.tpl", {
      channel_id   = local.dev_notifications_channel_id
      slackMessage = ":alert-noflash-slow: Initial scan complete for `<repositoryName>` <totalFindings> vulnerabilities found"
    })
  }
}
