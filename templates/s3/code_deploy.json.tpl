{
  "Version": "2012-10-17",
  "Id": "secure-transport-mgmt-dp-code-deploy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${intg_account_number}:role/IntgDPGithubActionsDeployLambdaRole",
          "arn:aws:iam::${staging_account_number}:role/StagingDPGithubActionsDeployLambdaRole",
          "arn:aws:iam::${prod_account_number}:role/ProdDPGithubActionsDeployLambdaRole",
          "arn:aws:iam::${intg_account_number}:role/IntgTerraformRole",
          "arn:aws:iam::${staging_account_number}:role/StagingTerraformRole",
          "arn:aws:iam::${prod_account_number}:role/ProdTerraformRole"
        ]
      },
      "Action": ["s3:GetObject", "s3:ListBucket", "s3:GetObjectTagging"],
      "Resource": [
        "arn:aws:s3:::mgmt-dp-code-deploy/*",
        "arn:aws:s3:::mgmt-dp-code-deploy"
      ]
    }
  ]
}
