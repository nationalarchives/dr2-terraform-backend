{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "${terraform_role_arn}"
      ]
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:eu-west-2:${account_id}:log-group:terraform-plan-outputs-*",
        "arn:aws:logs:eu-west-2:${account_id}:log-group:terraform-plan-outputs-*:log-stream:*"
      ]
    }
  ]
}
