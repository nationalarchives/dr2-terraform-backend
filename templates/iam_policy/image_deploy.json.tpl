{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr-public:CompleteLayerUpload",
        "ecr-public:GetAuthorizationToken",
        "ecr-public:UploadLayerPart",
        "ecr-public:InitiateLayerUpload",
        "ecr-public:BatchCheckLayerAvailability",
        "ecr-public:PutImage",
        "sts:GetServiceBearerToken"
      ],
      "Resource": "*"
    }
  ]
}
