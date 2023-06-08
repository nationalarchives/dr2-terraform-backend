{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "autoscaling:*",
        "cloudwatch:*",
        "ec2:*",
        "ecr:*",
        "elasticloadbalancing:*",
        "events:*",
        "iam:AttachGroupPolicy",
        "iam:CreateGroup",
        "iam:DeleteGroup",
        "iam:DetachGroupPolicy",
        "iam:GetGroup",
        "iam:ListAccountAliases",
        "iam:ListAttachedGroupPolicies",
        "kms:*",
        "lambda:*",
        "logs:*",
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
        "arn:aws:iam::${account_id}:role/alternat-*",
        "arn:aws:iam::${account_id}:role/aws-service-role*",
        "arn:aws:iam::${account_id}:policy/${environment}*",
        "arn:aws:iam::${account_id}:policy/alternat-*",
        "arn:aws:iam::${account_id}:instance-profile/${environment}*"
      ]
    }
  ]
}
