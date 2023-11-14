data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "intg_account_number" {
  name = "/mgmt/intg_account_number"
}

data "aws_ssm_parameter" "staging_account_number" {
  name = "/mgmt/staging_account_number"
}

data "aws_ssm_parameter" "prod_account_number" {
  name = "/mgmt/prod_account_number"
}

data "aws_ssm_parameter" "slack_token" {
  name            = "/mgmt/slack/token"
  with_decryption = true
}

data "aws_ssm_parameter" "dr2_notifications_slack_channel" {
  name = "/mgmt/slack/notifications/channel"
}
