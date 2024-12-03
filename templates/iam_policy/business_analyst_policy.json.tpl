{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AccessStepFunctions",
      "Effect": "Allow",
      "Action": [
        "states:DescribeStateMachineForExecution",
        "states:DescribeStateMachine",
        "states:DescribeExecution",
        "states:ListExecutions",
        "states:GetExecutionHistory"
      ],
      "Resource": [
        "arn:aws:states:eu-west-2:${account_id}:express:${environment}-dr2-ingest:*:*",
        "arn:aws:states:eu-west-2:${account_id}:execution:${environment}-dr2-ingest:*",
        "arn:aws:states:eu-west-2:${account_id}:stateMachine:${environment}-dr2-ingest",
        "arn:aws:states:eu-west-2:${account_id}:mapRun:${environment}-dr2-ingest/*:*"
      ]
    },
    {
      "Sid": "AccessNotificationLogs",
      "Effect": "Allow",
      "Action": [
        "logs:StartLiveTail",
        "logs:DescribeLogStreams",
        "logs:GetLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/${environment}-external-notifications:log-stream:*"
      ]
    },
    {
      "Sid": "ListResources",
      "Effect": "Allow",
      "Action": [
        "states:ListStateMachines",
        "logs:DescribeLogGroups"
      ],
      "Resource": "*"
    }
  ]
}