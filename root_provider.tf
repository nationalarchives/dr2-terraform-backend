terraform {
  backend "s3" {
    bucket         = "mgmt-dp-bootstrap-terraform-state"
    key            = "terraform.state"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "mgmt-dp-bootstrap-terraform-state-lock"
  }
}

provider "aws" {
  alias  = "intg"
  region = "eu-west-2"
  assume_role {
    role_arn     = "arn:aws:iam::${data.aws_ssm_parameter.intg_account_number.value}:role/IntgTerraformBootstrapRole"
    session_name = "terraform-backend"
  }
}

provider "aws" {
  alias  = "staging"
  region = "eu-west-2"
  assume_role {
    role_arn     = "arn:aws:iam::${data.aws_ssm_parameter.staging_account_number.value}:role/StagingTerraformBootstrapRole"
    session_name = "terraform-backend"
  }
}

provider "aws" {
  alias  = "prod"
  region = "eu-west-2"
  assume_role {
    role_arn     = "arn:aws:iam::${data.aws_ssm_parameter.prod_account_number.value}:role/ProdTerraformBootstrapRole"
    session_name = "terraform-backend"
  }
}
