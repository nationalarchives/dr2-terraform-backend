{
  "Version": "2012-10-17",
  "Id": "secure-transport-mgmt-dp-code-deploy",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::mgmt-dp-code-deploy",
        "arn:aws:s3:::mgmt-dp-code-deploy/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${intg_account_number}:role/IntgDPGithubActionsDeployLambdaRole",
          "arn:aws:iam::${staging_account_number}:role/StagingDPGithubActionsDeployLambdaRole",
          "arn:aws:iam::${prod_account_number}:role/ProdDPGithubActionsDeployLambdaRole"
        ]
      },
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::mgmt-dp-code-deploy/*",
        "arn:aws:s3:::mgmt-dp-code-deploy"
      ]
    }
  ]
}
