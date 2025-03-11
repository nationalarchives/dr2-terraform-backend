{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "autoscaling:*",
        "athena:*",
        "cloudtrail:*",
        "cloudwatch:*",
        "config:*",
        "datasync:*",
        "dynamodb:*",
        "ec2:*",
        "ecr:*",
        "ecs:*",
        "elasticloadbalancing:*",
        "events:*",
        "glue:*",
        "guardduty:*",
        "kms:*",
        "lambda:*",
        "logs:*",
        "pipes:*",
        "route53:*",
        "route53resolver:*",
        "securityhub:*",
        "ses:*",
        "s3:*",
        "secretsmanager:*",
        "sns:*",
        "sqs:*",
        "ssm:AddTagsToResource",
        "ssm:DeleteParameter",
        "ssm:DescribeParameters",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:ListTagsForResource",
        "ssm:PutParameter",
        "states:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:*"
      ],
      "Resource": [
        "arn:aws:iam::${account_id}:group/${environment}-dr2-custodial-copy",
        "arn:aws:iam::${account_id}:user/${environment}-dr2-custodial-copy",
        "arn:aws:iam::${account_id}:role/${environment}*",
        "arn:aws:iam::${account_id}:role/${environment_title}*",
        "arn:aws:iam::${account_id}:role/org-wiz-access-role",
        "arn:aws:iam::${account_id}:role/aws-service-role*",
        "arn:aws:iam::${account_id}:policy/${environment}*",
        "arn:aws:iam::${account_id}:policy/${environment_title}*",
        "arn:aws:iam::${account_id}:instance-profile/${environment}*"
      ]
    },
    {
      "Action": [
        "dynamodb:DescribeTable",
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::mgmt-dp-terraform-state",
        "arn:aws:s3:::mgmt-dp-terraform-state/*",
        "arn:aws:dynamodb:eu-west-2:${management_account_id}:table/mgmt-dp-terraform-state-lock"
      ]
    }
  ]
}
