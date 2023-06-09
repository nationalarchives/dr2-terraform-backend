{
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${code_deploy_bucket}/*",
        "arn:aws:s3:::${code_deploy_bucket}"
      ]
    }
  ],
  "Version": "2012-10-17"
}
