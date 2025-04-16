{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Allow account roles access",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${intg_role_arn}", "${staging_role_arn}", "${prod_role_arn}"]
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::mgmt-dp-terraform-state",
        "arn:aws:s3:::mgmt-dp-terraform-state/*"
      ]
    },
    {
      "Sid": "Allow deleting lock file object intg",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${intg_role_arn}"]
      },
      "Action": [
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::mgmt-dp-terraform-state/env:/intg/terraform.state.tflock"
      ]
    },
    {
      "Sid": "Allow deleting lock file object staging",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${staging_role_arn}"]
      },
      "Action": [
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::mgmt-dp-terraform-state/env:/staging/terraform.state.tflock"
      ]
    },
    {
      "Sid": "Allow deleting lock file object prod",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${prod_role_arn}"]
      },
      "Action": [
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::mgmt-dp-terraform-state/env:/prod/terraform.state.tflock"
      ]
    }
  ]
}
