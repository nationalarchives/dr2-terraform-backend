{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${terraform_github_role_arn}", "${admin_role_arn}"]
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "AllowStepFunctionRole",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${account_id}:role/${title_environment}-ingest-role"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "AllowAWSDataSync",
      "Effect": "Allow",
      "Principal": {
        "Service": "datasync.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
