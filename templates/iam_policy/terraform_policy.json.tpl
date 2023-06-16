{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "autoscaling:*",
        "cloudtrail:*",
        "cloudwatch:*",
        "config:*",
        "ec2:*",
        "ecr:*",
        "elasticloadbalancing:*",
        "events:*",
        "guardduty:*",
        "iam:*",
        "kms:*",
        "lambda:*",
        "logs:*",
        "route53:*",
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
        "ssm:PutParameter"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:*"
      ],
      "Resource": [
        "arn:aws:iam::${account_id}:role/${environment}*",
        "arn:aws:iam::${account_id}:role/${environment_title}*",
        "arn:aws:iam::${account_id}:role/aws-service-role*",
        "arn:aws:iam::${account_id}:policy/${environment}*",
        "arn:aws:iam::${account_id}:policy/${environment_title}*",
        "arn:aws:iam::${account_id}:instance-profile/${environment}*"
      ]
    }
  ]
}
