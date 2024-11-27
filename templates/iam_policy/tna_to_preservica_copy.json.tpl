{
  "Statement": [
    {
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListMultipartUploadParts",
        "s3:PutObject",
        "s3:GetObjectTagging",
        "s3:PutObjectTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::com.preservica.${preservica_tenant}.bulk1/*",
        "arn:aws:s3:::com.preservica.${preservica_tenant}.bulk2/*",
        "arn:aws:s3:::com.preservica.${preservica_tenant}.bulk3/*",
        "arn:aws:s3:::com.preservica.${preservica_tenant}.bulk4/*",
        "arn:aws:s3:::com.preservica.${preservica_tenant}.put.holding/*",
        "arn:aws:s3:::${ingest_staging_cache_bucket_name}/*"
      ],
      "Sid": "readWriteTnaAndPreservica"
    },
    {
      "Action": [
        "datasync:DescribeTaskExecution",
        "datasync:CancelTaskExecution",
        "datasync:DescribeLocation*",
        "datasync:CreateTask",
        "datasync:CreateLocationS3",
        "datasync:DescribeTask",
        "datasync:DescribeLocation*",
        "datasync:StartTaskExecution",
        "datasync:TagResource",
        "datasync:ListTagsForResource",
        "datasync:DeleteLocation",
        "datasync:DeleteTask",
        "datasync:UpdateTask",
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:datasync:eu-west-2:${account_id}:task/*",
        "arn:aws:datasync:eu-west-2:${account_id}:location/*",
        "arn:aws:datasync:eu-west-2:${account_id}:task/*/execution/*",
        "${tna_to_preservica_role_arn}"
      ],
      "Sid": "dataSyncTasks"
    },
    {
      "Sid": "dataSyncList",
      "Effect": "Allow",
      "Action": [
        "datasync:CreateLocationS3",
        "datasync:ListLocations",
        "datasync:ListTaskExecutions",
        "datasync:ListTasks",
        "logs:DescribeLogGroups"
      ],
      "Resource": "*"
    },
    {
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::com.preservica.${preservica_tenant}.bulk1",
        "arn:aws:s3:::com.preservica.${preservica_tenant}.bulk2",
        "arn:aws:s3:::com.preservica.${preservica_tenant}.bulk3",
        "arn:aws:s3:::com.preservica.${preservica_tenant}.bulk4",
        "arn:aws:s3:::com.preservica.${preservica_tenant}.put.holding",
        "arn:aws:s3:::${ingest_staging_cache_bucket_name}"
      ],
      "Sid": "listBucketPreservica"
    }
  ],
  "Version": "2012-10-17"
}
