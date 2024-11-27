{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Allow account roles access",
      "Effect": "Allow",
      "Principal": {
        "AWS": ${terraform_role_arns}
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::mgmt-dp-terraform-state",
        "arn:aws:s3:::mgmt-dp-terraform-state/*"
      ]
    }
  ]
}
