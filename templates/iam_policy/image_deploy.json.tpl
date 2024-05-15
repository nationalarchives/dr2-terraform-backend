{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr-public:BatchCheckLayerAvailability",
        "ecr-public:CompleteLayerUpload",
        "ecr-public:GetAuthorizationToken",
        "ecr-public:InitiateLayerUpload",
        "ecr-public:PutImage",
        "ecr-public:UploadLayerPart",
        "ecr:PutImage",
        "ecr:UploadLayerPart",
        "sts:GetServiceBearerToken"
      ],
      "Resource": "*"
    }
  ]
}
