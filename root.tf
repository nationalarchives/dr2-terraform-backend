locals {
  terraform_state_bucket_name = "mgmt-dp-terraform-state"
}
module "terraform_s3_bucket" {
  source                = "git::https://github.com/nationalarchives/da-terraform-modules.git//s3"
  bucket_name           = local.terraform_state_bucket_name
  bucket_policy         = templatefile("${path.module}/templates/s3/s3_secure_transport.json.tpl", { bucket_name = local.terraform_state_bucket_name })
  logging_bucket_policy = templatefile("${path.module}/templates/s3/s3_secure_transport_logging.json.tpl", { bucket_name = "${local.terraform_state_bucket_name}-logs" })
}

module "terraform_dynamo" {
  source        = "git::https://github.com/nationalarchives/da-terraform-modules.git//dynamo"
  hash_key      = "LockID"
  hash_key_type = "S"
  table_name    = "mgmt-dp-terraform-state-lock"
}
