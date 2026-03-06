{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PutEvents",
      "Effect": "Allow",
      "Action": "events:PutEvents",
      "Resource": "${event_bus_arn}"
    }
  ]
}
