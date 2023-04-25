terraform {
  backend "s3" {
    bucket         = "mgmt-dp-bootstrap-terraform-state"
    key            = "terraform.state"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "mgmt-dp-bootstrap-terraform-state-lock"
  }
}
