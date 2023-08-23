# DP Terraform Backend

This repository will store resources that need to be created before we can create other resources with terraform.

* S3 state bucket
* Dynamo state lock table
* Terraform roles and permissions for running in GitHub actions. 

The state bucket and lock table have been created manually for this repository.

## Running dr2-terraform-backend
There is a GitHub workflow which checks that the terraform is valid and formatted correctly before a pull request is merged but there is no deploy job.
The deployment will need to be done manually by someone with appropriate permissions. We may create a role in here so we can deploy it from GitHub actions in the future.
