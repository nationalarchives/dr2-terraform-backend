{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ssmglobal",
      "Effect": "Allow",
      "Action" : [
        "ssm:DescribeParameters"
      ],
      "Resource": "arn:aws:ssm:eu-west-2:${account_id}:*"
    },
    {
      "Sid" : "ssm",
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter"
      ],
      "Resource" : [
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/cost_centre",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/release/slack/webhook"
      ]
    },
    {
      "Sid": "route53",
      "Effect": "Allow",
      "Action" : [
        "route53:ListHostedZones"
      ],
      "Resource": "*"
    },
    {
      "Sid": "lambda",
      "Effect": "Allow",
      "Action": [
        "lambda:AddPermission",
        "lambda:CreateFunction",
        "lambda:DeleteFunction",
        "lambda:GetAlias",
        "lambda:GetFunction",
        "lambda:GetFunctionConcurrency",
        "lambda:GetFunctionConfiguration",
        "lambda:GetFunctionEventInvokeConfig",
        "lambda:GetLayerVersion",
        "lambda:GetLayerVersionPolicy",
        "lambda:GetPolicy",
        "lambda:ListVersionsByFunction",
        "lambda:ListTags",
        "lambda:RemovePermission",
        "lambda:TagResource",
        "lambda:UntagResource",
        "lambda:UpdateFunctionCode",
        "lambda:UpdateFunctionConfiguration"
      ],
      "Resource": [
        "arn:aws:lambda:eu-west-2:${account_id}:function:cloud-custodian-mailer",
        "arn:aws:lambda:eu-west-1:${account_id}:function:custodian*",
        "arn:aws:lambda:eu-west-2:${account_id}:function:custodian*"
      ]
    },
    {
      "Sid": "iam",
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": [
        "arn:aws:iam::${account_id}:role/Custodian*"
      ]
    },
    {
      "Sid": "events",
      "Effect": "Allow",
      "Action": [
        "events:ActivateEventSource",
        "events:DeactivateEventSource",
        "events:DescribeEventSource",
        "events:DescribeRule",
        "events:DeleteRule",
        "events:DisableRule",
        "events:EnableRule",
        "events:ListTargetsByRule",
        "events:PutRule",
        "events:PutTargets",
        "events:TagResource",
        "events:UntagResource"
      ],
      "Resource": [
        "arn:aws:events:eu-west-2:${account_id}:rule/cloud-custodian-mailer",
        "arn:aws:events:eu-west-1:${account_id}:rule/custodian*",
        "arn:aws:events:eu-west-2:${account_id}:rule/custodian*"
      ]
    }
  ]
}
